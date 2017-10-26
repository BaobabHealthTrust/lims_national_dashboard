namespace :api do
  desc "TODO"
  task vlstats: :environment do
    settings = YAML.load_file("#{Rails.root}/config/application.yml")
    site_name = settings["site_name"].downcase

    startkey = "#{site_name}_viral load_MYSTATUS_10000000000000"
    endkey = "#{site_name}_viral load_MYSTATUS_#{Time.now.strftime('%Y%m%d%H%M%S')}"

    map = {
        "pending" => ["drawn", "started", "completed"],
        "rejected" => ["rejected", "voided", 'specimen-rejected'],
        "completed" => ["verified"],
        "reviewed" => ["reviewed"]
    }

    map.each {|category, statuses|
      temp_result = []
      statuses.each do |status|
        temp_result += Order.by_test_type_and_status_and_datetime.startkey(
            [startkey.sub("MYSTATUS", status)]).endkey(
            [endkey.sub("MYSTATUS", status)]).to_a
      end
      map[category] = temp_result
    }

    File.open("public/api/vlstats.json","w") do |f|
      f.write(map.to_json)
    end
  end

  task  undispatched_vl: :environment do
      settings = YAML.load_file("#{Rails.root}/config/application.yml")
      site_name = settings["site_name"]
      type ="DBS (Free drop to DBS card)"
     
      rows = {}
      da = []
      counter =0
      Order.by_site_and_undispatched.each {|ord|
        if ord['sending_facility'] == site_name  
          da = ord
         rows[counter] = da
         counter = counter + 1
        end

      }

     
    File.open("public/api/undispatched_vl.json","w") do |f|
      f.write(rows.to_json)
    end
      
  end
end
