load "bin/tracking_number_service.rb"
$settings = YAML.load_file("#{Rails.root}/config/application.yml")
$configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
$counter_hash = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}
puts "Enter MYSQL HOST e.g 0.0.0.0"
host = gets.chomp

puts "Enter MYSQL User e,g root"
user = gets.chomp

puts "Enter MYSQL password"
password = STDIN.noecho(&:gets).chomp

puts "Enter healthdata database name"
healthdata_db = gets.chomp

puts "Enter ART database name"
art_db = gets.chomp

puts "Enter National LIMS Couch Database"
$lims_db = gets.chomp
$couch_query_url = "#{$configs['protocol']}://#{$configs['username']}:#{$configs['password']}@#{$configs['host']}:#{$configs['port']}/#{$lims_db}/_design/Order/_view/generic"
puts "ART Database: #{art_db} , HealthData database: #{healthdata_db},  SQL Username: #{user}, LIMS database: #{$lims_db}"

puts "Continue migration using details above? (y/n)"
proceed = gets.chomp

if proceed.downcase.strip != 'y'
  puts "Migration Stopped"
  Process.kill 9, Process.pid
end

puts "Initialising generic view in NLIMS database" 
Order.generic.count
puts "Finished initialisation"

File.open("#{Rails.root}/public/tracker.json", 'w') {|f|
      f.write({}.to_json) }

con = Mysql2::Client.new(:host => host,
                         :username => user,
                         :password => password,
                         :database => healthdata_db)

bart2_con = Mysql2::Client.new(:host => host,
                               :username => user,
                               :password => password,
                               :database => art_db)

total = con.query("SELECT COUNT(*) total FROM Lab_Sample INNER JOIN LabTestTable ON LabTestTable.AccessionNum = Lab_Sample.AccessionNum").first["total"].to_i
samples = con.query("SELECT * FROM Lab_Sample INNER JOIN LabTestTable ON LabTestTable.AccessionNum = Lab_Sample.AccessionNum")

bulk = {
    "docs" => []
}

def check_counter_per_date(date)
 date = date.strftime("%Y%m%d")
 if $counter_hash[date].blank? 
  do_reset(date)
 end 
end  

def do_reset(date)
  start_date = date.to_date.strftime("%Y%m%d000000")
  end_date = date.to_date.strftime("%Y%m%d235959")

  query_link = $couch_query_url + "?startkey=[\"#{start_date}\"]&endkey=[\"#{end_date}\"]"
  available_samples = JSON.parse(RestClient.get(URI.encode(query_link), :content_type => "application/json"))
  tracking_numbers = available_samples['rows'].collect{|h| h['id']}
  max_track_num    = tracking_numbers.max.to_s.strip
  puts max_track_num 
  puts date
  daily_counter = max_track_num.reverse[0 .. 2].reverse.to_i 
 
  if daily_counter >= 0
    file = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}
    todate = date.to_date.strftime("%Y%m%d")

    file[todate] = daily_counter + 1
    File.open("#{Rails.root}/public/tracker.json", 'w') {|f|

      f.write(file.to_json) }
  end
end 

samples.each_with_index do |row, i|
  check_counter_per_date(row['OrderDate'].to_date)

  puts "#{(i + 1)}/#{total}"
  patient = bart2_con.query(
                "SELECT n.given_name, n.middle_name, n.family_name, p.birthdate, p.gender, pid2.identifier npid, sd.earliest_start_date start_date
		 FROM patient_identifier pid
                    INNER JOIN person_name n ON n.person_id = pid.patient_id
                    INNER JOIN person p ON p.person_id = pid.patient_id
		    LEFT JOIN temp_earliest_start_date sd ON sd.patient_id = p.person_id
                    INNER JOIN patient_identifier pid2 ON pid2.patient_id = pid.patient_id AND pid2.voided = 0
                  WHERE pid.identifier = '#{row['PATIENTID']}' AND pid2.voided = 0 GROUP BY pid.patient_id
                ").as_json[0] # rescue {}

  tests = con.query("SELECT TestOrdered FROM LabTestTable WHERE AccessionNum = #{row['AccessionNum']}").as_json.collect{
      |h| 
h["TestOrdered"] = "Viral Load" if h["TestOrdered"] == "HIV_viral_load"
h["TestOrdered"]}

  results = con.query("SELECT * FROM Lab_Parameter
    LEFT JOIN codes_TestType ON Lab_Parameter.TestType = codes_TestType.TestType
    WHERE Sample_ID = #{row['Sample_ID']}").as_json

  formatted_results = {}
  results.each do |rst|
    next if rst['TESTVALUE'].blank?

    rst['TestName'] = "Viral Load" if rst['TestName'] = "HIV_DNA_PCR"
    formatted_results[rst['TestName']] = {}
    time = rst['TimeStamp'].to_datetime.strftime("%Y%m%d%H%M%S")
    formatted_results[rst['TestName']][time] = {
        "test_status"        => "completed",
        "datetime_started"   => "",
        "datetime_completed" => time,
        "remarks"            => "",
        "results"            => {
                                  rst['TestName'] => rst['TESTVALUE']
                                }
    }
  end

  bulk['docs'] << {
      "_id"=> TrackingNumberService.generate_tracking_number(row['OrderDate'].to_date),
      "patient"=> {
          "national_patient_id"=> patient["npid"],
          "first_name"=> patient['given_name'],
          "middle_name"=> (patient['middle_name'] == "Unknown" ? "" : patient["middle_name"]),
          "last_name"=> patient['family_name'],
          "date_of_birth"=> "#{patient['birthdate'].to_date.strftime('%Y%m%d')}000000",
          "gender"=> patient['gender'],
          "phone_number"=> ""
      },
      "sample_type"=> "Blood",
      "who_order_test"=> {
          "first_name"=> "",
          "last_name"=> "",
          "id_number"=> "#{row['OrderedBy']}",
          "phone_number"=> ""
      },
      "date_drawn"=>  (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}000000"),
      "date_dispatched"=> "",
      "art_start_date"=> (patient['start_date'].to_datetime.strftime("%Y%m%d%H%M%S") rescue nil),
      "date_received"=>  (row['RcvdAtLabDate'].blank? ? nil : "#{row['RcvdAtLabDate'].to_date.strftime('%Y%m%d')}000000"),
      "sending_facility"=> $settings['site_name'],
      "receiving_facility"=> $settings['target_lab'],
      "reason_for_test"=> "",
      "test_types"=> tests,
      "status"=> "Drawn",
      "district"=> $settings['district'],
      "priority"=> "Routine",
      "order_location"=> row['Location'],
      "results"=> formatted_results,
      "sample_status"=> "specimen-accepted"
  }
end

if bulk['docs'].length  > 0
  url = "#{$configs['protocol']}://#{$configs['username']}:#{$configs['password']}@#{$configs['host']}:#{$configs['port']}/#{$lims_db}/_bulk_docs"
  RestClient.post(url, bulk.to_json, :content_type => "application/json")
end
