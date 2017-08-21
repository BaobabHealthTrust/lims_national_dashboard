class ApiController < ApplicationController

  def viral_load_stats
    render :text => File.read("public/api/vlstats.json")
  end

  def vl_result_by_npid
		@vl_results = API.vl_result_by_npid(params)
    render :text => @vl_results
  end

  def patient_lab_trail
    @orders = API.patient_lab_trail(params)
    render :text => @orders.sort_by{|o| o['date_time']}.reverse.to_json
  end

  def validation_errors_list
    API.validation_errors_list
  end
end
