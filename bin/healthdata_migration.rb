load "bin/tracking_number_service.rb"
$settings = YAML.load_file("#{Rails.root}/config/application.yml")
$configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]

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

$lims_db = "#{$configs['prefix']}_#{$configs['suffix']}"
puts "Data to be migrated to NLIMS database #{$lims_db}"

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

$counter_hash = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}

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
	
  daily_counter = max_track_num.reverse[0 .. 2].reverse.to_i 

  if daily_counter >= 0
    file = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}
    todate = date.to_date.strftime("%Y%m%d")

    file[todate] = daily_counter + 1
    File.open("#{Rails.root}/public/tracker.json", 'w') {|f|

      f.write(file.to_json) }
  end
end 


def create_concept(con)
  concept_id = con.query("SELECT concept.concept_id AS concept_id FROM concept_name 
                        INNER JOIN concept ON concept.concept_id = concept_name.concept_id
                        WHERE concept_name.name='HIV viral load'").as_json[0]['concept_id']
  return concept_id
end

def create_encounter(con,patient_id,location_id,date_created,orderer)
  encounter_date = date_created 
  creator = orderer
  date_created = date_created
  voided = 0
  provider = 92
  voided_by = 1
  date_voided = date_created
  void_reason = ""
  
  changed_by = 1
  date_Changed = date_created
  encounter_id = order_counter = con.query("SELECT MAX(encounter_id) AS total FROM encounter").as_json[0]['total'].to_i +  1
  uuid = con.query("SELECT uuid()").as_json[0]['uuid()']
  encounter_type = con.query("SELECT encounter_type_id AS encout_type FROM encounter_type WHERE name ='LAB'").as_json[0]['encout_type']
  con.query("INSERT INTO encounter (encounter_id,encounter_type,patient_id,provider_id,location_id,encounter_datetime,creator,date_created,voided,voided_by,date_voided,void_reason,uuid,changed_by,date_changed) 
            VALUES('#{encounter_id}','#{encounter_type}','#{patient_id}','#{provider}','#{location_id}','#{encounter_date}','#{creator}','#{date_created}','#{voided}','#{voided_by}','#{date_voided}','#{void_reason}','#{uuid}','#{changed_by}','#{date_created}')")
  return encounter_id

end

samples.each_with_index do |row, i|
  check_counter_per_date(row['OrderDate'].to_date) if ($counter_hash[row['OrderDate']].blank? || $counter_hash[row['OrderDate'].to_date.strftime("%Y%m%d")].blank?)

  puts "#{(i + 1)}/#{total}"
 
  patient = bart2_con.query(
                "SELECT n.given_name, n.middle_name, n.family_name, p.birthdate, p.gender, pid2.identifier npid, pid2.patient_id npid2
		 FROM patient_identifier pid
                    INNER JOIN person_name n ON n.person_id = pid.patient_id
                    INNER JOIN person p ON p.person_id = pid.patient_id
                    INNER JOIN patient_identifier pid2 ON pid2.patient_id = pid.patient_id AND pid2.voided = 0
                  WHERE pid.identifier = '#{row['PATIENTID']}' AND pid2.voided = 0
                ").as_json[0] # rescue {}

  orderer = bart2_con.query(
                "SELECT n.given_name, n.middle_name, n.family_name FROM users u
                    INNER JOIN person_name n ON n.person_id = u.person_id
                  WHERE u.user_id = '#{row['OrderedBy']}' AND n.voided = 0 
									ORDER BY u.date_created DESC
                ").as_json[0] rescue {}

  tests = con.query("SELECT TestOrdered FROM LabTestTable WHERE AccessionNum = #{row['AccessionNum']}").as_json.collect{
      |h| 
h["TestOrdered"] = "Viral Load" if h["TestOrdered"] == "HIV_viral_load"
h["TestOrdered"]}

  results = con.query("SELECT * FROM Lab_Parameter
    LEFT JOIN codes_TestType ON Lab_Parameter.TestType = codes_TestType.TestType
    WHERE Sample_ID = #{row['Sample_ID']}").as_json
  
  order_date = "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}"
  formatted_results = {}
  results.each do |rst|
    next if rst['TESTVALUE'].blank?
      time = rst['TimeStamp'].to_datetime.strftime("%Y%m%d%H%M%S")
      time =  order_date if time < order_date
        rst['TestName'] = "Viral Load" if rst['TestName'] = "HIV_DNA_PCR"
        formatted_results[rst['TestName']] = {}      
        formatted_results[rst['TestName']][time] = {
            "test_status"        => "verified",
            "datetime_started"   => "",
            "datetime_completed" => time,
            "remarks"            => "",
            "results"            => {
                                      rst['TestName'] => "#{rst['Range'].to_s.strip} #{rst['TESTVALUE'].to_s.strip}"
                                    }
        }
    
  end
  next if patient.blank? || orderer.blank?
  doc = {
      "patient"=> {
          "national_patient_id"=> patient["npid"],
          "first_name"=> patient['given_name'],
          "middle_name"=> (patient['middle_name'] == "Unknown" ? "" : patient["middle_name"]),
          "last_name"=> patient['family_name'],
          "date_of_birth"=> "#{patient['birthdate'].to_date.strftime('%Y%m%d')}000000",
          "gender"=> patient['gender'],
          "phone_number"=> ""
      },
      "sample_type"=> "DBS (Free drop to DBS card)",
      "who_order_test"=> {
          "first_name"=> orderer['given_name'],
          "last_name"=> orderer['family_name'],
          "id_number"=> "#{row['OrderedBy']}",
          "phone_number"=> ""
      },
      "date_drawn"=>  (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}"),
      "date_dispatched"=> "",
      "art_start_date"=> (patient['start_date'].to_datetime.strftime("%Y%m%d%H%M%S") rescue nil),
      "date_received"=>  (row['RcvdAtLabDate'].blank? ? nil : "#{row['RcvdAtLabDate'].to_date.strftime('%Y%m%d')}" + "#{row['RcvdAtLabTime'].to_time.strftime('%H%M%S')}"),
      "sending_facility"=> $settings['site_name'],
      "receiving_facility"=> $settings['target_lab'],
      "reason_for_test"=> "",
      "test_types"=> tests,
      "status"=> "Drawn",
      "district"=> $settings['district'],
      "priority"=> "Routine",
      "order_location"=> row['Location'],
      "results"=> formatted_results,
      "sample_status"=> "specimen-accepted",
      "date_time"   => (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
  }

  t_num =  TrackingNumberService.generate_tracking_number(row['OrderDate'].to_date)
  puts t_num
  url = "#{$configs['protocol']}://#{$configs['username']}:#{$configs['password']}@#{$configs['host']}:#{$configs['port']}/#{$lims_db}/#{t_num}"
  res  = JSON.parse(RestClient.put(url, doc.to_json, :content_type => "application/json"))
  
  if res['ok'] == true
    order_type = "4"
    orderer_id = row['OrderedBy']   
    instructions = ""
    start_date = (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
    expiry_date = (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
    discountined = 0
    discountined_date = (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
    discountined_by = row['OrderedBy']
    discountined_reason = 1
    creator = row['OrderedBy']
    date_created = (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
    voided = 0
    voided_by = row['OrderedBy']
    voided_date = (row['OrderDate'].blank? ? "" : "#{row['OrderDate'].to_date.strftime('%Y%m%d')}" + "#{row['OrderTime'].to_time.strftime('%H%M%S')}")
    voided_reason = ""
    patient_id = patient["npid2"]
    accession_number = res['id']
    obs_id = 1
    
    discountined_reason_non_coded = ""
    order_location =  265

    concept_id = create_concept(bart2_con)
    encouter_id = create_encounter(bart2_con,patient_id,order_location,date_created,orderer_id)    

    order_counter = bart2_con.query("SELECT MAX(order_id) AS total FROM orders").as_json[0]['total'].to_i +  1
    uuid = order_counter
    bart2_con.query("INSERT INTO orders VALUES('#{order_counter}','#{order_type}','#{concept_id}','#{orderer_id}','#{encouter_id}','#{instructions}','#{start_date}','#{expiry_date}','#{discountined}','#{discountined_date}','#{discountined_by}','#{discountined_reason}','#{creator}','#{date_created}','#{voided}','#{voided_by}','#{voided_date}','#{voided_reason}','#{patient_id}','#{accession_number}','#{obs_id}','#{uuid}','#{discountined_reason_non_coded}')")
    
  end

end



def create_observation()

end



puts "Done!!"

=begin
	if bulk['docs'].length  < 0
		url = "#{$configs['protocol']}://#{$configs['username']}:#{$configs['password']}@#{$configs['host']}:#{$configs['port']}/#{$lims_db}/_bulk_docs"
		RestClient.post(url, bulk.to_json, :content_type => "application/json")
	end
=end

