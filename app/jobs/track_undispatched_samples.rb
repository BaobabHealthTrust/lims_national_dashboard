require 'sync'

class UndispatchedSamples
    include SuckerPunch::Job
    workers 1   

    def perform()
        begin
         

            settings = YAML.load_file("#{Rails.root}/config/application.yml")
            site_name = settings["site_name"]
            type ="DBS (Free drop to DBS card)"
        
            rows = {}
            da = []
            counter =0
            Order.by_site_and_undispatched.each {|ord|
              
                if ord['sending_facility'] == site_name  && ord['sample_type'] == type
                   
                    da = ord
                    rows[counter] = da
                    counter = counter + 1
                end

            }
           
            File.open("public/api/undispatched_vl.json","w") do |f|
              f.write(rows.to_json)
            end      
            UndispatchedSamples.perform_in(1)
        rescue
            UndispatchedSamples.perform_in(1)
        end

    end


end
