class HomeController < ApplicationController
  def home
    @sites_enabled = Site.by_enabled.key(true).each
  end

  def map_main

    @sites = []
    (Site.by_enabled.key(true)).each do |source|
      site = {
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
