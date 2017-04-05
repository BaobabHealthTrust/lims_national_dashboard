require 'sync'

class AutoPing
  include SuckerPunch::Job
  workers 1

  def perform()

    begin
      if Rails.env == 'development'
        SuckerPunch.logger.info "Pinging sites"
      end

      sites = Site.by_enabled.key(true)
      data = YAML.load_file("#{Rails.root}/public/sites.yml") rescue {}

      sites.each do |site|
        data[site.code] = {} if data[site.code].blank?
        if Sync.up?(site.host)
          data[site.code]['online'] = true
          data[site.code]['last_seen'] = "#{Time.now}"
        else
          data[site.code]['online'] = false
        end

        File.open("#{Rails.root}/public/sites.yml","w") do |file|
          file.write data.to_yaml
        end

        AutoPing.perform_in(30)
      end
    rescue
      SuckerPunch.logger.info "Error while perfoming ping"
      AutoPing.perform_in(30)
    end
  end
end