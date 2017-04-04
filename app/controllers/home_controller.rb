class HomeController < ApplicationController
  def home

    last_run_time = File.mtime("#{Rails.root}/public/sites.yml").to_time rescue Time.now

    now = Time.now

    if (now - last_run_time).to_f > 30
      AutoPing.perform_in(1)
      sleep 4
    end


    sites = YAML.load_file("#{Rails.root}/public/sites.yml") rescue {}
    @sites_enabled = Site.by_enabled.key(true).each

    @sites_enabled.each do |site|
      site['online'] = sites[site.code]['online'] rescue false
      last_seen =  sites[site.code]['last_seen'].to_datetime rescue nil

      if last_seen.present?
        months_diff = ((Time.now - last_seen.to_time)/(60*60*24*30)).to_i
        days_diff = ((Time.now - last_seen.to_time)/(60*60*24)).to_i
        hrs_diff = ((Time.now - last_seen.to_time)/(60*60)).to_i
        min_diff = ((Time.now - last_seen.to_time)/(60)).to_i
        sec_diff = (Time.now - last_seen.to_time).to_i

        if site['online'] && sec_diff < 30
          last_seen = "<span style='color: green !important'>Online</span>".html_safe
        elsif months_diff > 0
          last_seen = "#{months_diff} months ago"
        elsif days_diff > 0
          last_seen = "#{days_diff} days ago"
        elsif hrs_diff > 0
          last_seen = "#{hrs_diff} hrs ago"
        elsif min_diff > 0
          last_seen = "#{min_diff} mins ago"
        else
          last_seen = "#{sec_diff} secs ago"
        end
      else
        last_seen = "?"
      end

      site['last_seen'] = last_seen
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
