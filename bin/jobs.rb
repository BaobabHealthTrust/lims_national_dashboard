#!/usr/bin/ruby

require 'sync'

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
end

File.open("#{Rails.root}/public/sites.yml","w") do |file|
  file.write data.to_yaml
end

#Check sync within every 10 minutes after every hour i.e if cronjob runs per minute
if Time.now.strftime('%M').to_i % 60 < 10
  Sync.sync_all
end

