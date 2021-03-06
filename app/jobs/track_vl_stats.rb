require 'sync'

class VlStats
    include SuckerPunch::Job
    workers 1   

    def perform()
        
        begin
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

            VlStats.perform_in(60)
        rescue
            VlStats.perform_in(60)
        end
    end
end
