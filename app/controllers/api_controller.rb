class ApiController < ApplicationController

  def viral_load_stats
    render :text => File.read("public/api/vlstats.json")
  end

  def undispatched_viral_load
     render :text => File.read("public/api/undispatched_vl.json")
  end

  def vl_result_by_npid
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

      if (order['sample_status'] || order['status']).match(/rejected/i)
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
			results = results.sort_by{|r| r[0]}
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



  def share_lab_catalog
      Lab.push_lab_cat_log(params)

      render :text => "added".to_json
  end

  def drawn_un_drawn_sample

  end

  def add_test_to_order    
    tests = params[:test]
    tests = tests.delete_if(&:empty?)      
    tracking_number = params[:_id]
    got_results = {}
    got_tests = {}
    order = Order.find(tracking_number)
    got_results = order.results
    got_tests =  order.test_types
    got_tests += tests
      
    tests.each do |r|    
      
       data  = {         
             "#{DateTime.now.strftime('%Y%m%d%H%M%S')}" => {
                 "test_status"=> "Drawn",
                 "remarks" => "",
                 "datetime_started" => "#{DateTime.now.strftime('%Y%m%d%H%M%S')}",
                 "datetime_completed" => "",
                 "results" => {
                 }
             }           
        }           

        got_results[r] = data
    end
    order.test_types= got_tests
    order.results= got_results
    order.save()
    render :json => "is done".to_json
  end

  def retrieve_lab_catalog
    lab_name =  params[:lab]    
    samples =  Lab.find(lab_name)
    render :json => samples
  end

  def capture_sample_dispatcher
    p_id = params[:p_id]
    l_name = params[:l_name]
    f_name = params[:f_name]
    phone = params[:phone]    
    tracking_number =  params[:id]  
      
      Order.capture_sample_dispatcher(tracking_number,p_id,l_name,f_name,phone)
      
      render :json => "is done".to_json
  end

  def validation_errors_list
    require 'api.rb'
    render :text => API.validation_errors_list(params).to_json
  end

  def pull_vl_by_id
    results = Order.find(params['id']) rescue []
    render :text => results.to_json
  end


end
