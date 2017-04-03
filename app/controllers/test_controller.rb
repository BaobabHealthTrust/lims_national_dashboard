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
      
       @total_orders = Order.by_datetime_and_sending_facility

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
          who_order_test_phoneNumber int 
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
    end

    if !File.exists?("#{Rails.root}/app/assets/tests.sql")
      FileUtils.touch("#{Rails.root}/app/assets/tests.sql")
    end

    if !File.exists?("#{Rails.root}/app/assets/test_trails.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_trails.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/test_results.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_results.sql"
    end

    order_id = 1
    testid = 1
    results_incrementor = 0
    trials_incrementor = 0

    Order.by_datetime_and_sending_facility.each do |order|
        empty = "'" + "'"
        File.open("#{Rails.root}/app/assets/orders.sql","a") do |txt|  

          sending_facility = "'" + order['sending_facility'] + "'"
          
          
          txt.puts "\r" +  "INSERT INTO orders VALUES(
                                 #{order_id},
                                 #{"'" + order['_id'] + "'" rescue empty},
                                 #{sending_facility rescue empty},
                                 #{"'" + order['receiving_facility'] + "'" rescue empty},
                                 #{"'" + order['sample_type'] + "'" rescue empty},
                                 #{"'" + order['who_order_test']['first_name'] + "'" rescue empty},
                                 #{"'" + order['who_order_test']['last_name'] + "'" rescue empty},
                                 #{"'" + order['who_order_test']['id'] + "'" rescue empty},
                                 #{"'" + order['who_order_test']['phone_number'] + "'" rescue empty}
                            ):"
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
              txt.puts "\r" +  "INSERT INTO tests VALUES(
                                  #{testid},
                                  #{"'" + order['_id']  + "'" rescue empty},
                                  #{"'" + test_name  + "'" rescue empty},
                                  #{"'" + time_stamps[ts_counts-1][1]['test_status']  + "'" rescue empty},
                                  #{"'" + time_stamps[0][1]['datetime_started']  + "'" rescue empty},
                                  #{"'" + date_time_completed  + "'" rescue empty},
                                  #{"'" + panel  + "'" rescue empty}
                                ):"
            end

            for counter in 0...ts_counts 
              trials_incrementor = trials_incrementor+1
              File.open("#{Rails.root}/app/assets/test_trails.sql","a") do |txt|              
                txt.puts "\r" + "INSERT INTO test_trails VALUES(
                                    #{trials_incrementor},
                                    #{"'" + testid.to_s  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][0]  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][1]['test_status']  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][1]['remarks']  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][1]['who_updated']['first_name']  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][1]['who_updated']['last_name']  + "'" rescue empty},
                                    #{"'" + time_stamps[counter][1]['who_updated']['id']  + "'" rescue empty}
                                  ):"
              end

            end
           
            if (ts_counts >=4)
                result_names_count = time_stamps[ts_counts-1][1]['results'].keys.length
                result_names =  time_stamps[ts_counts-1][1]['results'].keys.to_a
                
                for count in 0...result_names_count
                  results_incrementor = results_incrementor+1
                  File.open("#{Rails.root}/app/assets/test_results.sql", "a") do |txt|
                    txt.puts "\r" + "INSERT INTO test_results VALUES(
                                       #{results_incrementor},
                                       #{"'" + testid.to_s + "'" rescue empty},
                                       #{"'" + result_names[count] + "'" rescue empty},
                                       #{"'" + time_stamps[ts_counts-1][1]['results'][result_names[count]] + "'" rescue empty},
                                       #{"'" + time_stamps[ts_counts-1][1]['remarks'] + "'" rescue empty}
                                  ):"
                  end
                end    
            end
            testid = testid+1            
        end      
    end  

    render :text => tables  
  end



  def load_orders

    orders = File.read("#{Rails.root}/app/assets/orders.sql")
    order = orders.split(":")
    order = order[params[:number].to_i]
    pushOrders(order)
    
    render :text => order

  end

  def pushOrders(data)

    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(data.to_s)

  end

  def orders_total
    orders = File.read("#{Rails.root}/app/assets/orders.sql")
    order = orders.split(":")
  
    render :text => order.length
    
  end



  def load_tests

    tests = File.read("#{Rails.root}/app/assets/tests.sql")
    tst = tests.split(":")
    tst = tst[params[:number].to_i]
    pushTests(tst)
    
    render :text => tst

  end
  def pushTests(data)

    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(data.to_s)

  end
  def tests_total
    tests = File.read("#{Rails.root}/app/assets/tests.sql")
    tst = tests.split(":")
  
    render :text => tst.length
    
  end



  def load_tests_results

    results = File.read("#{Rails.root}/app/assets/test_results.sql")
    rst = results.split(":")
    rst = rst[params[:number].to_i]
    pushTestsResults(rst)
    
    render :text => rst

  end
  def pushTestsResults(data)

    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(data.to_s)

  end
  def test_results_total
    tests = File.read("#{Rails.root}/app/assets/test_results.sql")
    tst = tests.split(":")
   
    render :text => tst.length
    
  end



  def load_trails

    trails = File.read("#{Rails.root}/app/assets/test_trails.sql")
    trls = trails.split(":")
    trls = trls[params[:number].to_i]
    pushTrails(trls)
    
    render :text => trls

  end
  def pushTrails(data)

    configs = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]    
    client = Mysql2::Client.new(:host => "localhost", :username => "#{configs['username']}", :password => "#{configs['password']}", :database => "#{configs['database']}")
    client.query(data.to_s)

  end
  def trails_total
    trails = File.read("#{Rails.root}/app/assets/test_trails.sql")
    trls = trails.split(":")
  
    render :text => trls.length
    
  end


end
