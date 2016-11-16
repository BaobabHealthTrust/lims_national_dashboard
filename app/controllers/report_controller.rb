class ReportController < ApplicationController
  def reports

  end

  def report_parameters

  end

  def general_report_data
    csv = []
    #[display_name, [test_types], [result_types], [value, [value_modifiers]], min_age, max_age, other, count]

    case params[:quarter]
      when "Q1"
        @months = ["January", "February", "March"]
        start_time = "#{params[:year]}0100000000"
        end_time   = "#{params[:year]}0331235959"
        startA = "#{params[:year]}0100000000"
        startB = "#{params[:year]}0200000000"
        startC = "#{params[:year]}0300000000"
        endA = "#{params[:year]}0131235959"
        endB = "#{params[:year]}0231235959"
        endC = "#{params[:year]}0331235959"
      when "Q2"
        @months = ["April", "May", "June"]
        start_time   = "#{params[:year]}0400000000"
        end_time   = "#{params[:year]}0631235959"
        startA = "#{params[:year]}0400000000"
        startB = "#{params[:year]}0500000000"
        startC = "#{params[:year]}0600000000"
        endA = "#{params[:year]}0431235959"
        endB = "#{params[:year]}0531235959"
        endC = "#{params[:year]}0631235959"
      when "Q3"
        @months = ["July", "August", "September"]
        start_time = "#{params[:year]}0700000000"
        end_time   = "#{params[:year]}0931235959"
        startA = "#{params[:year]}0700000000"
        startB = "#{params[:year]}0800000000"
        startC = "#{params[:year]}0900000000"
        endA = "#{params[:year]}0731235959"
        endB = "#{params[:year]}0831235959"
        endC = "#{params[:year]}0931235959"
      when "Q4"
        @months = ["October", "November", "December"]
        start_time = "#{params[:year]}1000000000"
        end_time   = "#{params[:year]}1231235959"
        startA = "#{params[:year]}1000000000"
        startB = "#{params[:year]}1100000000"
        startC = "#{params[:year]}1200000000"
        endA = "#{params[:year]}1031235959"
        endB = "#{params[:year]}1131235959"
        endC = "#{params[:year]}1231235959"
      else
        raise "Missing Quarter for Year #{params[:year]}".to_s
    end
    map = [0, 0, 0]
    #[display_name, [test_types], [result_types], [value, value_modifiers], [min_age, modifier], [max_age, modifier], other, count]
    options = []
    params[:test_type] = params[:test_type].split("__")
    params[:result_names] = params[:result_names].gsub(/CD4\spercent/i, "CD4 %").split("__")
    params[:wards] = params[:wards].split("__")

    $data.each do |order|
      results = order.results || {}
      result_names = results.keys.collect{|r| r.strip}

      test_type = (result_names & params[:test_type]).first

      next if (test_type.blank? && params[:test_type][0] != "aval")
      measures = results[test_type]["results"]
      r_names = (measures.keys & params[:result_names]).first rescue nil
      next if r_names.blank? && params[:result_names][0] != "aval"

      ward = (params[:wards] & [order["order_location"]]) rescue nil
      next if !params[:wards].blank? && ward.blank?

      age = 0
      date_of_birth = order['patient']['date_of_birth']
      if params[:min_age].present? || params[:max_age].present?
        age = -1
        next if date_of_birth.blank?
        (date_of_birth = date_of_birth.to_date) rescue (next) # bad date format e.g 0000-00-00
        age = ((order['date_time'].to_date - date_of_birth)/31557600).round # year
      end

      if(order['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end
      if(order['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end
      if(order['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end

      if params[:value] == "aval" && !measures.blank?
        map[result_index] += 1
        next
      end

      if !params[:value].blank? && params[:value] != "aval"
        value = nil
        value = params["value"].split("__") & measures.values if r_names.blank?
        value = measures[r_names] if value.blank?

        next if value.blank?
        if !params[:value_modifier].blank?
          value = value.scan(/\d+\.\d+/).first rescue ""
          next if value.blank?
          v = eval("#{value} #{params["value_modifier"]} #{params[:value]}")
          if v == true
            map[result_index] += 1
            next
          end
        else
          if value.strip == params[:value]
            map[result_index] += 1
            next
          end
        end
      end

      if params[:result_names][0] == "aval" && !results[test_type].blank?
        map[result_index] += 1
      end

    end

    render :text => map.to_json
  end

  def general_counts
    csv = []
    #[display_name, [test_types], [result_types], [value, [value_modifiers]], min_age, max_age, other, count]

    case params[:quarter]
      when "Q1"
        @months = ["January", "February", "March"]
        start_time = "#{params[:year]}0100000000"
        end_time   = "#{params[:year]}0331235959"

      when "Q2"
        @months = ["April", "May", "June"]
        start_time   = "#{params[:year]}0400000000"
        end_time   = "#{params[:year]}0631235959"
      when "Q3"
        @months = ["July", "August", "September"]
        start_time = "#{params[:year]}0700000000"
        end_time   = "#{params[:year]}0931235959"

      when "Q4"
        @months = ["October", "November", "December"]
        start_time = "#{params[:year]}1000000000"
        end_time   = "#{params[:year]}1231235959"

      else
        raise "Missing Quarter for Year #{params[:year]}".to_s
    end

    $data = Order.generic.startkey([start_time]).endkey([end_time]).each
  end

end
