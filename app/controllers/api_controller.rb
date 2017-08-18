class ApiController < ApplicationController

  def viral_load_stats
    render :text => File.read("public/api/vlstats.json")
  end

  def vl_result_by_npid
		API.vl_result_by_npid
  end

  def patient_lab_trail


    startkey = "#{params[:npid].strip}_10000000000000"
    endkey = "#{params[:npid].strip}_#{Time.now.strftime('%Y%m%d%H%M%S')}"

    orders = []
    Order.by_national_id_and_datetime.startkey([startkey]).endkey([endkey]).each {|order|
      orders << order
    }

    render :text => orders.sort_by{|o| o['date_time']}.reverse.to_json
  end

  def validation_errors_list
    API.validation_errors_list
  end
end
