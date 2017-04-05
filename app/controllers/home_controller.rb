class HomeController < ApplicationController
  def home

    last_run_time = File.mtime("#{Rails.root}/public/sites.yml").to_time rescue Time.now

    now = Time.now
    if (now - last_run_time).to_f > 30
      SuckerPunch::Queue.clear
      #AutoPing.perform_in(1)
      AutoSync.perform_in(1)
    end


    sites = YAML.load_file("#{Rails.root}/public/sites.yml") rescue {}
    @sites_enabled = Site.by_enabled.key(true).each

    @sites_enabled.each do |site|
      site['last_seen'] =  "Offline"
      site['online'] = false
      if Sync.up?(site.host, site.port)
        site['online'] = true
        site['last_seen'] = "<span style='color: green !important'>Online</span>".html_safe
      end
    end

  end

  def map_main

    @sites = []
    sites = YAML.load_file("#{Rails.root}/public/sites.yml") rescue {}

    (Site.by_enabled.key(true)).each do |source|
      site = {
          'online' => (sites[source.code]['online'] rescue false),
          'region' => source["region"],
          'x' => source["x"].to_f,
          'y' =>source["y"].to_f,
          'sitecode' => source["code"],
          'name' => source["name"]
      }

      @sites << site
    end

    render :layout => false
  end

end
