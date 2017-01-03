class ApiController < ApplicationController

  def viral_load_stats
    render :text => File.read("public/api/vlstats.json")
  end

  def vl_result_by_npid

    results = []
    startkey = "#{params[:npid].strip}_10000000000000"
    endkey = "#{params[:npid].strip}_#{Time.now.strftime('%Y%m%d%H%M%S')}"

    vl_orders = []
    Order.by_national_id_and_datetime.startkey([startkey]).endkey([endkey]).each {|order|
      vl_orders << order if (order['test_types'] & ['Viral Load', "Viral load", "VL"]).length > 0
    }

    vl_orders.each { |order|
      result_a = (order['results']['Viral load'] || order['results']['Viral Load'] || order['results']['VL'])
      timestamp = result_a.keys.last

      next if order['status'].downcase.strip == 'reviewed'
      test_status = result_a[timestamp]['test_status']
      results = [order.results] if !result_a[timestamp]['results'].blank? && ['completed', 'verified'].include?(test_status.downcase.strip)
    }

    render :text => results.to_json
  end
end
