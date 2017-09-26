require 'mysql2'
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
      
       @total_orders = Order.by_datetime_and_sending_facility.count
  end

  def createHeaders
     File.open("#{Rails.root}/app/assets/orders.sql","a") do |txt|  
         
          txt.puts "\r" +  "INSERT INTO orders VALUES"
     end

     File.open("#{Rails.root}/app/assets/tests.sql","a") do |txt|  
         
          txt.puts "\r" +  "INSERT INTO tests VALUES"
     end

     File.open("#{Rails.root}/app/assets/test_trails.sql","a") do |txt|  
         
          txt.puts "\r" +  "INSERT INTO test_trails VALUES"
     end

     File.open("#{Rails.root}/app/assets/test_results.sql","a") do |txt|  
         
          txt.puts "\r" +  "INSERT INTO test_results VALUES"
     end

     File.open("#{Rails.root}/app/assets/patients.sql","a") do |txt|  
         
          txt.puts "\r" +  "INSERT INTO patients VALUES"
     end

  end

 def appendSemicolon
     File.open("#{Rails.root}/app/assets/orders.sql","a") do |txt|  
         
          txt.puts "\r" +  ";"
     end

     File.open("#{Rails.root}/app/assets/tests.sql","a") do |txt|  
         
          txt.puts "\r" +  ";"
     end

     File.open("#{Rails.root}/app/assets/test_trails.sql","a") do |txt|  
         
          txt.puts "\r" +  ";"
     end

     File.open("#{Rails.root}/app/assets/test_results.sql","a") do |txt|  
         
          txt.puts "\r" +  ";"
     end

     File.open("#{Rails.root}/app/assets/patients.sql","a") do |txt|  
         
          txt.puts "\r" +  ";"
     end

  end

  def getStructure
     configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

    tables = [
        "CREATE TABLE orders (
          id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
          tracking_number VARCHAR(255),
          sending_facility VARCHAR(255),
          receiving_facility VARCHAR(255),
          sample_type VARCHAR(255),
          who_order_test_fName VARCHAR(255),
          who_order_test_SName VARCHAR(255),
          who_order_test_id VARCHAR(255),
          who_order_test_phoneNumber VARCHAR(255),
          art_start_date datetime,
          date_dispatched datetime,
          date_drawn datetime,
          date_received datetime,
          date_time datetime,
          district VARCHAR(255),
          order_location VARCHAR(255),
          priority VARCHAR(50),
          reason_for_test VARCHAR(255),
          status VARCHAR(255)
        )",

        "CREATE TABLE tests (
          id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
          order_id VARCHAR(255),
          test_name VARCHAR(255),
          status VARCHAR(40),
          date_time_started datetime,
          date_time_completed datetime,
          panel VARCHAR(255)
        )",

        "CREATE TABLE test_trails (
          id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
          test_id VARCHAR(255),
          time_stamp datetime,
          test_status VARCHAR(40),
          test_remarks VARCHAR(255),
          who_updated_fName VARCHAR(255),
          who_updated_sName VARCHAR(255),
          who_updated_id VARCHAR(255)
        )",

        "CREATE TABLE test_results (
         id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
         test_id  VARCHAR(255),
         result_name VARCHAR(100),
         result_value VARCHAR(255),
         test_remarks VARCHAR(255)
        )",

        "CREATE TABLE patients (
         id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
         order_id VARCHAR(100),
         national_id  VARCHAR(255),
         first_name VARCHAR(100),
         last_value VARCHAR(255),
         middle_name VARCHAR(255),
         date_of_birth datetime,
         gender VARCHAR(50),
         phone_number VARCHAR(100)
        )"

    ]
  

    db_create = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}")
    db_create.query("DROP DATABASE IF exists #{configs['database']}")
    db_create.query("CREATE DATABASE #{configs['database']}")

    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")

    tables.each do |table|
      client.query(table)     
    end
  
    if !File.exists?("#{Rails.root}/app/assets/orders.sql")
      FileUtils.touch "#{Rails.root}/app/assets/orders.sql"
    else
      FileUtils.rm("#{Rails.root}/app/assets/orders.sql")
      FileUtils.touch "#{Rails.root}/app/assets/orders.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/tests.sql")
      FileUtils.touch("#{Rails.root}/app/assets/tests.sql")
    else
      FileUtils.rm("#{Rails.root}/app/assets/tests.sql")
      FileUtils.touch "#{Rails.root}/app/assets/tests.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/test_trails.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_trails.sql"
    else
      FileUtils.rm("#{Rails.root}/app/assets/test_trails.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_trails.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/test_results.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_results.sql"
    else
      FileUtils.rm("#{Rails.root}/app/assets/test_results.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_results.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/patients.sql")
      FileUtils.touch "#{Rails.root}/app/assets/patients.sql"
    else
      FileUtils.rm("#{Rails.root}/app/assets/patients.sql")
      FileUtils.touch "#{Rails.root}/app/assets/patients.sql"
    end

    order_id = 1
    testid = 1
    results_incrementor = 0
    trials_incrementor = 0
    patient_incrementor = 0
    checker = 0
    order_values = []
    order_counter = 0
    test_counter = 0
    trail_counter = 0
    results_counter = 0
    patient_counter =0
    
    createHeaders()

    Order.by_datetime_and_sending_facility.each do |order|

        empty = "'" + "'"
        File.open("#{Rails.root}/app/assets/orders.sql","a") do |txt|  

          sending_facility = "'" + escape_characters(order['sending_facility']) + "'"
          if (order_counter==0)
              txt.puts "\r" +  "(#{escape_characters(order_id)},#{"'" + escape_characters(order['_id']) + "'" rescue empty},#{sending_facility rescue empty},#{"'" + escape_characters(order['receiving_facility']) + "'" rescue empty},#{"'" + escape_characters(order['sample_type']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['first_name']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['last_name']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['id']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['phone_number']) + "'" rescue 0},#{"'" + escape_characters(order['art_start_date']) + "'" rescue empty},#{"'" + escape_characters(order['date_dispatched']) + "'" rescue empty},#{"'" + escape_characters(order['date_drawn']) + "'" rescue empty},#{"'" + escape_characters(order['date_received']) + "'" rescue empty},#{"'" + escape_characters(order['date_time']) + "'" rescue empty},#{"'" + escape_characters(order['district']) + "'" rescue empty},#{"'" + escape_characters(order['order_location']) + "'" rescue empty},#{"'" + escape_characters(order['priority']) + "'" rescue empty},#{"'" + escape_characters(order['reason_for_test']) + "'" rescue empty},#{"'" + escape_characters(order['status']) + "'" rescue empty})"
              order_counter = order_counter + 1
          else
               txt.puts "\r" +  ",(#{escape_characters(order_id)},#{"'" + escape_characters(order['_id']) + "'" rescue empty},#{sending_facility rescue empty},#{"'" + escape_characters(order['receiving_facility']) + "'" rescue empty},#{"'" + escape_characters(order['sample_type']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['first_name']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['last_name']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['id']) + "'" rescue empty},#{"'" + escape_characters(order['who_order_test']['phone_number']) + "'" rescue 0},#{"'" + escape_characters(order['art_start_date']) + "'" rescue empty},#{"'" + escape_characters(order['date_dispatched']) + "'" rescue empty},#{"'" + escape_characters(order['date_drawn']) + "'" rescue empty},#{"'" + escape_characters(order['date_received']) + "'" rescue empty},#{"'" + escape_characters(order['date_time']) + "'" rescue empty},#{"'" + escape_characters(order['district']) + "'" rescue empty},#{"'" + escape_characters(order['order_location']) + "'" rescue empty},#{"'" + escape_characters(order['priority']) + "'" rescue empty},#{"'" + escape_characters(order['reason_for_test']) + "'" rescue empty},#{"'" + escape_characters(order['status']) + "'" rescue empty})"
          end

        end

        patient_incrementor = patient_incrementor + 1
        File.open("#{Rails.root}/app/assets/patients.sql","a") do |txt|  

          if (patient_counter==0)
              txt.puts "\r" +  "(#{patient_incrementor},#{"'" + escape_characters(order['_id']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['national_patient_id']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['first_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['last_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['middle_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['date_of_birth']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['gender']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['phone_number']) + "'" rescue empty})"
              patient_counter =  patient_counter + 1
          else
              txt.puts "\r" +  ",(#{patient_incrementor},#{"'" + escape_characters(order['_id']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['national_patient_id']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['first_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['last_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['middle_name']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['date_of_birth']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['gender']) + "'" rescue empty},#{"'" + escape_characters(order['patient']['phone_number']) + "'" rescue empty})"
          end

        end

        order_id = order_id + 1
        order['results'].each do |tests| 
            
          test_name = tests[0]
          ts_counts = tests[1].length
          time_stamps = tests[1].to_a        
          date_time_completed = nil if (ts_counts < 4)                      
          date_time_completed = time_stamps[ts_counts-1][1]['date_time_completed'] if (ts_counts >=5)
          panel = ""
          counter = 0          

            File.open("#{Rails.root}/app/assets/tests.sql","a") do |txt| 
              
              if (test_counter ==0)
                  txt.puts "\r" +  "(#{escape_characters(testid)},#{"'" + escape_characters(order['_id'])  + "'" rescue empty},#{"'" + escape_characters(test_name)  + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['test_status'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[0][1]['datetime_started'])  + "'" rescue empty},#{"'" + escape_characters(date_time_completed)  + "'" rescue empty},#{"'" + escape_characters(panel)  + "'" rescue empty})"
                  test_counter = test_counter + 1
              else
                  txt.puts "\r" +  ",(#{escape_characters(testid)},#{"'" + escape_characters(order['_id'])  + "'" rescue empty},#{"'" + escape_characters(test_name)  + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['test_status'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[0][1]['datetime_started'])  + "'" rescue empty},#{"'" + escape_characters(date_time_completed)  + "'" rescue empty},#{"'" + escape_characters(panel)  + "'" rescue empty})"
              end

            end

            for counter in 0...ts_counts 
              trials_incrementor = trials_incrementor+1
              File.open("#{Rails.root}/app/assets/test_trails.sql","a") do |txt|              
                if (trail_counter==0)  
                  txt.puts "\r" + "(#{trials_incrementor},#{"'" + escape_characters(testid.to_s)  + "'" rescue empty},#{"'" + time_stamps[counter][0]  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['test_status'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['remarks'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['first_name'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['last_name'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['id'])  + "'" rescue empty})"
                  trail_counter = trail_counter + 1
                else
                  txt.puts "\r" + ",(#{trials_incrementor},#{"'" + escape_characters(testid.to_s)  + "'" rescue empty},#{"'" + time_stamps[counter][0]  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['test_status'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['remarks'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['first_name'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['last_name'])  + "'" rescue empty},#{"'" + escape_characters(time_stamps[counter][1]['who_updated']['id'])  + "'" rescue empty})"
                end

              end

            end
           
            if (ts_counts >=4)
                result_names_count = time_stamps[ts_counts-1][1]['results'].keys.length rescue "0"
                if (result_names_count == "0")
                
                else
                 result_names =  time_stamps[ts_counts-1][1]['results'].keys.to_a
                  
                  for count in 0...result_names_count
                    results_incrementor = results_incrementor+1
                    File.open("#{Rails.root}/app/assets/test_results.sql", "a") do |txt|
                      if(results_counter==0) 
                        txt.puts "\r" + "(#{results_incrementor},#{"'" + escape_characters(testid.to_s) + "'" rescue empty},#{"'" + escape_characters(result_names[count]) + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['results'][result_names[count]]) + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['remarks']) + "'" rescue empty})"
                        results_counter = results_counter + 1
                      else
                        txt.puts "\r" + ",(#{results_incrementor},#{"'" + escape_characters(testid.to_s) + "'" rescue empty},#{"'" + escape_characters(result_names[count]) + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['results'][result_names[count]]) + "'" rescue empty},#{"'" + escape_characters(time_stamps[ts_counts-1][1]['remarks']) + "'" rescue empty})"
                      end
                            
                    end
                  end  
                end

            end
            testid = testid+1            
        end  
        checker = checker + 1    
    end  
    appendSemicolon()

    render :text => tables  
  end

  def escape_characters(value)

      value = value.to_s.gsub(/'/,"")
      value = value.to_s.gsub(/,/," ")
      value = value.to_s.gsub(/;/," ")
      value = value.to_s.gsub(")"," ")
      value = value.to_s.gsub("("," ")
      value = value.to_s.gsub("/"," ")
      value = value.to_s.gsub('\\'," ")


    return value
  end

  def load_orders
    tests = File.read("#{Rails.root}/app/assets/orders.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)

    render :text => "fine"
  end

  def demo

  end

  def demoStructure
    tests = File.read("#{Rails.root}/app/assets/orders.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)

    render :text => "fine"
  end

  def load_tests
    tests = File.read("#{Rails.root}/app/assets/tests.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)
    
     render :text => "fine"
  end
 

  def load_tests_results
    tests = File.read("#{Rails.root}/app/assets/test_results.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)

     render :text => "fine"
  end

  def load_trails
    tests = File.read("#{Rails.root}/app/assets/test_trails.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)

     render :text => "fine"
  end

  def load_patients
    tests = File.read("#{Rails.root}/app/assets/patients.sql")
    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(tests)

     render :text => "fine"
  end
 


end
