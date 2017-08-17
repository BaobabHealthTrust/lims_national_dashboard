class ApiController < ApplicationController

  def viral_load_stats
    render :text => File.read("public/api/vlstats.json")
  end

  def vl_result_by_npid

		API.vl_result_by_npid
    results = []
    last_order = {}

    test_status = params[:test_status].split("__") rescue nil
    test_status = ['verified'] if test_status.blank?

    startkey = "#{params[:npid].strip}_10000000000000"
    endkey = "#{params[:npid].strip}_#{Time.now.strftime('%Y%m%d%H%M%S')}"

    vl_orders = []
    Order.by_national_id_and_datetime.startkey([startkey]).endkey([endkey]).each {|order|
      vl_orders << order if (order['test_types'] & ['Viral Load']).length > 0
    }

    ([vl_orders.last]).each { |order|
      next if order.nil?

      result_a = order['results']['Viral Load']
      timestamp = result_a.keys.sort.last

      order_status = result_a[timestamp]['test_status']
      rst = result_a[timestamp]["results"]

      if order['status'].match(/rejected/i)
        rst = "Rejected"
        order_status = "Rejected"
      end

      rst = {"Viral Load" => "Rejected"} if (["rejected"].include?(rst.downcase) rescue false)

      if (!rst.blank? && test_status.include?(order_status.downcase.strip)) || order['status'].match(/rejected/i)
        results << [timestamp, rst, order_status, timestamp]
        last_order = order
      end
    }

    if ((params[:raw].to_s == "true" ) rescue false)
      render :text => last_order.to_json
    else
      render :text => results.to_json
    end
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
    options = params.reject{|x, v| x.match(/controller|action/)}
    rule = options['category']
    status = options['status']

    if params[:all] == 'true'
      start_date="1917-05-25 08:57:06 UTC".to_time
      end_date=Time.now
    else
      start_date = params[:start_date].to_time
      end_date = params[:end_date].to_time
    end

    start_key = "#{rule}_#{status}_#{start_date.strftime("%Y%m%d%H%M%S")}"
    end_key   = "#{rule}_#{status}_#{end_date.strftime("%Y%m%d%H%M%S")}"

    if current_user.user_role == "Administrator"
      data = Order.by_error_category_status_and_datetime.startkey([start_key]).endkey([end_key]).each
    else
      data = Order.by_error_category_status_and_datetime_on_my_site.startkey([start_key]).endkey([end_key]).each
    end

    results = []
    data.each do |d|
      order = Order.find(d['tracking_number'])

      results << {
          'date_registered' => order['date_time'].to_date.strftime("%d/%b/%Y"),
          'patient_name' => ((order['patient']['first_name'] + ' ' + order['patient']['middle_name'] + order['patient']['last_name']).gsub(/\s+/, ' ') rescue nil),
          'npid' => order['patient']['national_patient_id'],
          'sex' => order['patient']['gender'],
          'dob' => (order['patient']['date_of_birth'].to_date.strftime("%d/%b/%Y") rescue nil),
          'sender' => order['sending_facility'],
          'receiver' => order['receiving_facility']
      }
    end

    render :text => results.to_json
  end
end
