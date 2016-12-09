
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

    if params[:min_age].to_i == -1 || params[:max_age].to_i == -1
      params[:unknown_age] = true
    end
    sample_types = params[:sample_type].downcase.split("__").collect{|s| s.strip}

    $data.each do |order|
      results = order.results
      result_names = results.keys.collect{|r| r.strip}

      #sample type mismatch
      next if !sample_types.blank? && !sample_types.include?(order["sample_type"].downcase.strip)

      #test type mismatch
      test_type = (result_names & params[:test_type]).first
      next if (test_type.blank? && params[:test_type][0] != "aval")

      measures = (results[test_type] || {}) rescue {}

      measures.each do |r, v|
        measures[r] = v.strip
      end

      r_names = (measures.keys & params[:result_names]).first

      #result paramater mismatch
      next if r_names.blank? && params[:result_names][0] != "aval"

      #source location mismatch
      ward = (params[:wards] & [order["order_location"]]) rescue nil
      next if !params[:wards].blank? && ward.blank?

      #age contraints
      age = 0
      date_of_birth = order['patient']['date_of_birth']
      if params[:min_age].present? || params[:max_age].present?
        age = -1
        next if date_of_birth.blank?
        age = ((order['date_time'].to_time - date_of_birth.to_time)/31557600) rescue -1 # year quick conversion
        #run age filters
        next if params[:unknown_age] && age > -1
        next if !params[:min_age].blank? && !age.between?(params[:min_age].to_i, 120)
        next if !params[:max_age].blank? && !age.between?(0, params[:max_age].to_i)
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

      value_check = measures[r_names] rescue nil
      next if (value_check == "0" || value_check == 0)

      if params[:value] == "aval" && !measures.blank?
        map[result_index] += 1
        next
      end

      if params[:value] != "aval"
        value = nil

        value = params["value"].split("__") & measures.values if r_names.blank?

        if !value.blank?
          map[result_index] += 1
          next
        end

        value = measures[r_names]
        if !params[:value_modifier].blank? && params[:value_modifier].match(/^has/) && !value.blank?

          value_modifiers = params[:value_modifier].split("__")
          stop = false

          argv = params[:value_modifier].split(" ").last
          argv = "+" if argv == "plus"
          arr_check = value.scan(argv)
          if arr_check.length > 0
            map[result_index] += 1
            next
          end
        end

        if params[:value_modifier].match(/\<|\>/) && !value.blank?
          value = value.scan(/\d\.\d/).first if value.match(/\d\.\d/)
          v = eval("#{value} #{params["value_modifier"]}") rescue ""
          if v == true || !v.blank?
            map[result_index] += 1
            next
          end
        end

        if value == params[:value]
          map[result_index] += 1
          next
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
