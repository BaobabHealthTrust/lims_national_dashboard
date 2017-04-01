require "mysql"
class TestController < ApplicationController
  def tests
    @cur_page = (params[:page].present? ? params[:page] : 1).to_i
    @settings = YAML.load_file("#{Rails.root}/config/application.yml")
    @pages = []
    @keys = Order.generic.keys
    @start_year = Order.generic.first['date_time'][0 .. 3].to_i  rescue Date.today.year
    start_year = (params['year'].present? ? params['year'] : '0000')
    start_month = (params['month'].present? ? params['month'] : '00').to_s.rjust(2, '0')
    start_day = (params['day'].present? ? params['day'] : '00').to_s.rjust(2, '0')

    end_year = params['year'].present? ? params['year'] : Date.today.year
    end_month = (params['month'].present? ? params['month'] : '12').to_s.rjust(2, '0')
    end_day = (params['day'].present? ? params['day'] : '31').to_s.rjust(2, '0')

    start_time = "#{start_year}#{start_month}#{start_day}000000"
    end_time = "#{end_year}#{end_month}#{end_day}235959"

    #Query orders
    @count =  Order.generic.startkey([start_time]).endkey([end_time]).count
    @page_size = @settings['page_size']
    @page_count = (@count/@page_size).ceil
    search_criteria = params["search-criteria"]
    search_value = params["search-value"]

    case search_criteria
      when 'tracking_number'
        @tests = [Order.find(search_value)].compact
      when 'by_datetime_and_sending_facility'
        @tests = Order.by_datetime_and_sending_facility.startkey(
            [search_value + "_" + start_time]).endkey([search_value + "_" + end_time]
        ).page(@cur_page).per(@page_size).each
      when 'by_datetime_and_receiving_facility'
        @tests = Order.by_datetime_and_receiving_facility.startkey(
            [search_value + "_" +  start_time]).endkey([search_value + "_" + end_time]
        ).page(@cur_page).per(@page_size).each
      when 'by_datetime_and_sample_type'
        @tests = Order.by_datetime_and_sample_type.startkey(
            [search_value + "_" + start_time]).endkey([search_value + "_" + end_time]
        ).page(@cur_page).per(@page_size).each
      when 'by_datetime_and_test_type'
        @tests = Order.by_datetime_and_test_type.startkey(
            [search_value + "_" + start_time]).endkey([search_value + "_" + end_time]
        ).page(@cur_page).per(@page_size).each
      when 'by_datetime_and_district'
        @tests = Order.by_datetime_and_district.startkey(
            [search_value + "_" + start_time]).endkey([search_value + "_" + end_time]
        ).page(@cur_page).per(@page_size).each
      else
        @tests =  Order.generic.startkey([start_time]).endkey([end_time]).page(@cur_page).per(@page_size).each
    end

    @tests = @tests.to_a
    #raise (start_time + " ---- " + end_time).inspect
    #pagination management
    if @page_count <= 20
      @page_count.times do |i|
        @pages << i + 1
      end
    else
      plus = 0; minus = 0

      ((@cur_page - 10) .. @cur_page).each do |i|
        if i <= 0
          plus += 1
        else
          @pages << i
        end
      end

      ((@cur_page + 1) .. (@cur_page + 10)).each do |i|
        if i > @page_count
          minus += 1
        else
          @pages << i
        end
      end

      plus.times do |i|
        @pages = @pages + [@pages.last + 1]
      end

      minus.times do |i|
        @pages = [@pages.first - 1] + @pages
      end
    end
  end

  def build_mysql_database
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

    tables = [
        "CREATE TABLE order (
          id int(10) NOT NULL AUTO_INCREMENT,
          tracking_number VARCHAR(255),
          sending_facility VARCHAR(255),
          receiving_facility VARCHAR(255),
          sample_type VARCHAR(255),
          who_order_test_fName VARCHAR(255),
          who_order_test_SName VARCHAR(255),
          who_order_test_id VARCHAR(255),
          who_order_test_phoneNumber int 
        )",

        "CREATE TABLE test (
          id int(10) NOT NULL AUTO_INCREMEN
          order_id VARCHAR(255),
          test_name VARCHAR(255),
          status VARCHAR(40),
          date_time_started datetime,
          date_time_completed datetime,
          panel VARCHAR(255)
        )",

        "CREATE TABLE test_trail (
          id int(10) NOT NULL AUTO_INCREMEN,
          test_id VARCHAR(255),
          time_stamp datetime,
          test_status VARCHAR(40),
          test_remarks VARCHAR(255),
          who_updated_fName VARCHAR(255),
          who_updated_sName VARCHAR(255),
          who_updated_id VARCHAR(255)
        )",

        "CREATE TABLE test_result (
         id int(10) NOT NULL AUTO_INCREMEN,
         test_id  VARCHAR(255),
         result_name VARCHAR(100),
         result_value VARCHAR(255),
         test_remarks VARCHAR(255)
        )"
    ]

    db = Mysql2::Client.new(:host=>config["host"], :username=>config["username"], :password=>config["password"])

    `mysql -u #{config["user"]} -p#{config["password"]} -e 'DROP database if exists #{config['database']}'`
    `mysql -u #{config['user']} -p#{config['password']} -e 'CREATE database #{config['database']}'`

    tables.each do |table|
      `mysql -u #{config['user']} -p#{config['password']} #{config['database']} << #{table}`
    end

    if !File.exists?("#{Rails.root}/app/assets/order.sql")
      FileUtils.touch "#{Rails.root}/app/assets/order.sql"
      File.open("#{Rails.root}/app/assets/order.sql","a") do |txt| txt.puts "\r" + "USE #{configs['database']}" end
    end

    if !File.exists?("#{Rails.root}/app/assets/test.sql")
      FileUtils.touch("#{Rails.root}/app/assets/test.sql")
      File.open("#{Rails.root}/app/assets/test.sql","a") do |txt| txt.puts "\r" + "USE #{configs['database']}" end
    end

    if !File.exists?("#{Rails.root}/app/assets/test_trail.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_trail.sql"
      File.open("#{Rails.root}/app/assets/test_trail.sql","a") do |txt| txt.puts "\r" + "USE #{configs['database']}" end
    end

    if !File.exists?("#{Rails.root}/app/assets/test_result.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_result.sql"
      File.open("#{Rails.root}/app/assets/test_result.sql","a") do |txt| txt.puts "\r" + "USE #{configs['database']}" end
    end

    Order.by_datetime_and_sending_facility.each do |order|

        File.open("#{Rails.root}/app/assets/order.sql","a") do |txt|  

          txt.puts "\r" +  "INSERT INTO order VALUES(
                                 #{order['_id']},
                                 #{order['sending_facility']},
                                 #{order['receiving_facility']},
                                 #{order['sample_type']},
                                 #{order['who_order_test']['first_name']},
                                 #{order['who_order_test']['last_name']},
                                 #{order['who_order_test']['id']},
                                 #{order['who_order_test']['phone_number']}
                            )"
        end


        order['results'].each do |tests|   
          test_name = tests[0]
          ts_counts = tests[1].length
          time_stamps = tests[1].to_a        
          date_time_completed = nil if (ts_counts < 4)                      
          date_time_completed = time_stamps[ts_counts-1][1]['date_time_completed'] if (ts_counts >=5)
          panel = ""
          counter = 0
          

            File.open("#{Rails.root}/app/assets/test.sql","a") do |txt| 
              txt.puts "\r" +  "INSERT INTO test VALUES(
                                  #{order['_id']},
                                  #{test_name},
                                  #{time_stamps[ts_counts-1][1]['test_status']},
                                  #{time_stamps[0][1]['datetime_started']},
                                  #{date_time_completed},
                                  #{panel},
                                )"
            end

            for counter in 0...ts_counts 
              File.open("#{Rails.root}/app/assets/test_trail.sql","a") do |txt|              
                txt.puts "\r" + "INSERT INTO test_trail VALUES(
                                    #{order['_id']},
                                    #{time_stamps[counter][0]},
                                    #{time_stamps[counter][1]['test_status']},
                                    #{time_stamps[counter][1]['remarks']},
                                    #{time_stamps[counter][1]['who_updated']['first_name'] rescue nil},
                                    #{time_stamps[counter][1]['who_updated']['last_name'] rescue nil},
                                    #{time_stamps[counter][1]['who_updated']['id'] rescue nil}
                                  )"
               end
            end

           
            if (ts_counts >=4)
                result_names_count = time_stamps[ts_counts-1][1]['results'].keys.length
                result_names =  time_stamps[ts_counts-1][1]['results'].keys.to_a
                
                for count in 0...result_names_count
                  File.open("#{Rails.root}/app/assets/test_result.sql", "a") do |txt|
                    txt.puts "\r" + "INSERT INTO test_result VALUES(
                                       #{order['_id']},
                                       #{result_names[count]},
                                       #{time_stamps[ts_counts-1][1]['results'][result_names[count]]},
                                       #{time_stamps[ts_counts-1][1]['remarks']}
                                  )"
                  end
                end    
            end
        end      
    end   
  end
end
