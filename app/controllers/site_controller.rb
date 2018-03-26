class SiteController < ApplicationController

  def index
    @sites = Site.by_enabled.key(false).each
    @sites_enabled = Site.by_enabled.key(true).each
  end
  def add_site
    render :layout => false
  end

  def edit_site
    render :layout => false
  end

  def map
    @region = params["region"] rescue nil
    @label = nil

    @region = "blank" if @region.blank?

    case @region.to_s.downcase
      when "centre"
        @label = "Central Region"
      when "north"
        @label = "Northern Region"
      when "south"
        @label = "Southern Region"
    end

    @x = nil
    @y = nil

    if !params["x"].blank?
      @x = params["x"]
    end

    if !params["y"].blank?
      @y = params["y"]
    end

    render :layout => false
  end

  def save_site
    response = ["Site could not be added", nil]
    site = Site.by_name.key(params[:site]).first
    if !site.blank?
      site.enabled = true
      site.code = params[:code]
      site.host = params[:host]
      site.port = params[:port]
      site.save

      response = ["Site successfully saved", true]
    end
    # result =  Site.add_site(params[:site], params[:code],params[:host],params[:port],params[:region],params[:x],params[:y])
    render :text => response.to_json
  end

  def update_current_site

    Site.current = Site.by_name.key(params[:site]).last
    render :layout => false
  end

  def get_current_site

    site_name = Site.current
    render :text => (Site.current.name rescue "").to_json

  end

  def update_site
    response = ["Site could not be updated", nil]
    site = Site.by_name.key(params[:site]).first
    if !site.blank?
      site.code = params[:code]
      site.host = params[:host]
      site.port = params[:port]
      site.save

      response = ["Site successfully updated", true]
    end
    #result =  Site.update_site(params[:site_old],params[:site], params[:code],params[:host],params[:port],params[:region],params[:x],params[:y])
    render :text => response.to_json
  end
end
