require 'api'
class ReportController < ApplicationController
   

  @quarter = 0
  @year = 0
  @result_index  = 0


  def reports
      @error_count = 0
      if current_user.user_role == "Administrator"
        @error_count = Order.by_error_category_and_datetime.count
      else
        @error_count = Order.by_error_category_and_datetime_on_my_site.count
      end
  end

  def report_parameters

    if params[:type] == 'validations'
      render :template => '/report/validation_parameters'
    end
  end

  def view_validations

    if params[:all] == "true"
      if current_user.user_role == "Administrator"
        @stats = API.admin_stats
      else
        @stats = API.stats
      end
    else
      if current_user.user_role == "Administrator"
        @stats = API.admin_stats(params[:start_date].to_time, "#{params[:end_date].to_date} 23:59:59".to_time)
      else
        @stats = API.stats(params[:start_date].to_time, "#{params[:end_date].to_date} 23:59:59".to_time)
      end
    end
  end
  
  def general_report_data

    #[display_name, [test_types], [result_types], [value, [value_modifiers]], min_age, max_age, other, count]
    @csv_quarter =  params[:quarter]
    @csv_year = params[:year]

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
    result_index = 0  
    counter = params[:id].to_i 
    @csv_data = []

    #[display_name, [test_types], [result_types], [value, value_modifiers], [min_age, modifier], [max_age, modifier], other, count]
    options = []
    params[:test_type] = params[:test_type].gsub(/\_ampersand\_/, "&").split("__")
    params[:result_names] = params[:result_names].gsub(/CD4\spercent/i, "CD4 %").split("__")
    params[:wards] = params[:wards].split("__")
    if params[:min_age].to_i == -1 || params[:max_age].to_i == -1
      params[:unknown_age] = true
    end
    sample_types = params[:sample_type].downcase.split("__").collect{|s| s.strip} 
    # to get information on analyzed samples (based on SAMPLE TYPES)
  if !sample_types.blank? && params[:test_type][0] == "aval"
    $data.each do | order_sample|
      if(order_sample['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end
      if(order_sample['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end
      if(order_sample['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end
      if ['Blood','Pleural Fluid','Ascitic Fluid','Pericardial Fluid','Peritoneal Fluid'].include?(order_sample['sample_type']) 
         if params[:display] == "Sample Fluids with organisms" 
                if order_sample['results'].keys.include?("Culture & Sensitivity")
                   keys_got = order_sample['results']['Culture & Sensitivity'].keys
                   count = keys_got.count
                   ava_organism =   order_sample['results']['Culture & Sensitivity'][keys_got[count-1]]['results']
                   next if ava_organism.blank?
                   if ava_organism['Culture'] ="Growth"
                     map[result_index] += 1
                     next
                  end
                end
            elsif params[:display] == "Total number of sample fluids analysed" 
               map[result_index] += 1
               next
            end
      end
            if sample_types[0].upcase.to_s == order_sample['sample_type'].upcase.to_s  
                if params[:display] == "Others"
                  if order_sample['results'].include?("MC&S")
                       map[result_index] += 1
                       next
                  end
                elsif params[:display] == "Other body fluids"
                     if order_sample['results'].include?("Sterile Fluid Analysis")
                       map[result_index] += 1
                       next
                      end
                else
                     map[result_index] += 1
                    next
                end
            end
    end
  elsif params[:display] == "Percentage of contaminates over total blood cultures" && params[:test_type][0] == "Culture & Sensitivity" 
     blood_sample_counter = 0
     cont = 0
     value_percnt = 0
     $data.each do | order_sample|        
        if(order_sample['date_time'].to_i.between?(startA.to_i, endA.to_i))
          result_index = 0
        end
        if(order_sample['date_time'].to_i.between?(startB.to_i, endB.to_i))
          result_index = 1
        end
        if(order_sample['date_time'].to_i.between?(startC.to_i, endC.to_i))
          result_index = 2
        end
        next if !order_sample["results"].include?(params[:test_type][0])
        next if !order_sample["sample_type"].include?("Blood") 
        main_key = order_sample['results'].keys     
        sub_keys = order_sample['results']["Culture & Sensitivity"].keys
        next if !main_key.include?("Culture & Sensitivity")             
              count = sub_keys.count
              rs = order_sample['results']["Culture & Sensitivity"][sub_keys[count-1]]["results"]
              next if rs.blank?
              blood_sample_counter =   blood_sample_counter + 1            
              if rs["Culture"].strip == "Growth of contaminants"
                cont = cont + 1                 
              end
    end      
    if cont != 0 && blood_sample_counter !=0
        value_percnt = (cont.to_f/blood_sample_counter) * 100
        for i in 1..value_percnt.to_i do
          map[result_index] += 1
        end
    end
  elsif params[:display] == "Positive Syphilis screening on antenatal mothers" && params[:test_type][0] == "Syphilis Test" 
    $data.each do | order_sample|
      control = 0
      if(order_sample['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end
      if(order_sample['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end
      if(order_sample['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end
      next if !order_sample["results"].include?(params[:test_type][0])
      next if !order_sample["order_location"].include?("ANC") && !order_sample["order_location"].include?("EM OPD")
      main_key = order_sample['results'].keys
      sub_keys = order_sample['results']["Syphilis Test"].keys
      count = sub_keys.count
              rs = order_sample['results']["Syphilis Test"][sub_keys[count-1]]["results"]
              next if rs.blank?
                 if (rs["RPR"] == "Reactive" && rs["VDRL"] == "Reactive") && rs["TPHA"] == "Reactive"
                map[result_index] += 1 
             end
    end      
  elsif params[:display] == "Positive Syphilis tests" && params[:test_type][0] == "Syphilis Test" 
   $data.each do | order_sample|
      control = 0
      if(order_sample['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end
      if(order_sample['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end
      if(order_sample['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end
      next if !order_sample["results"].include?(params[:test_type][0])
      main_key = order_sample['results'].keys
      sub_keys = order_sample['results']["Syphilis Test"].keys
      count = sub_keys.count
              rs = order_sample['results']["Syphilis Test"][sub_keys[count-1]]["results"]
              next if rs.blank?
                 if (rs["RPR"] == "Reactive" && rs["VDRL"] == "Reactive") && rs["TPHA"] == "Reactive"
                map[result_index] += 1 
             end
    end      
  elsif params[:display] == "No Results" && params[:test_type][0] == "TB Tests"
    $data.each do | order_sample|
      next if order_sample["status"] != "specimen-rejected"
      if(order_sample['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end
      if(order_sample['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end
      if(order_sample['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end
      map[result_index] += 1
    end
# getting information based on TEST TYPES
  else
    i = 0
    #iterating through all the orders captured in the database (COUCH DB)
    $data.each do |order|
     tests= []
     rst = [] 
      i = 0
      for i  in 0...params[:test_type].count do
            results = order.results
            #getting keys of results HAS from database
            result_names = results.keys.collect{|r| r.strip}
            #sample type mismatch//// checking it sample type from database matches the sample type posted by the HAS from the controller
            next if !sample_types.blank? && !sample_types.include?(order["sample_type"].downcase.strip)
            #test type mismatch      
            tests = params[:test_type]
            test_type = tests[i] if result_names.include?(tests[i])
            next if (test_type.blank? && test_type != "aval")
            measures = (results[test_type] || {}) rescue {}
            measures.each do |r, v|
              measures[r] = v.strip
            end
            rst =  params[:result_names]
            r_names = rst[i] if measures.keys.include?(rst[i])
            #result paramater mismatch
            next if r_names.blank? && rst[i] != "aval"
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
              value = "MTB DETECTED" if value == "MTB Detected High" || value == "MTB Detected Low" || value == "MTB Detected Medium"
              if value == params[:value]
                map[result_index] += 1
                next
             end
            end
            if params[:result_names][0] == "aval" && !results[test_type].blank? 
              map[result_index] += 1
            end
      end
    end
  end 
   @csv_data[counter] = [["#{params[:display]}","#{map[result_index]}","0","0"]]
   render :text => map.to_json
  end

def exp
   na = "LIMS_#{params[:year]}_#{params[:quarter]}_General_Counts2000000000000000000"
    name = na+".csv"
    path = "~/Documents/ #{name}"
    CSV.open(File.expand_path(path), "w+") do |csv_file|
        @csv_data.each do |info|
          puts info
         csv_file << info
       end
    end
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
