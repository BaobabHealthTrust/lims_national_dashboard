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
        "
        CREATE TABLE order (
          id ,
          tracking_number VARCHAR(255), etc)
        ",

        "
        CREATE TABLE test (id, order_id, etc)
        ",

        "
        CREATE TABLE test_trail (id, test_id, etc)
        ",

        "
        CREATE TABLE test_result (id, test_id, etc)
        "
    ]

    `mysql -u #{config['user']} -p#{config['password']} -e 'DROP database if exists #{config['database']}'`
    `mysql -u #{config['user']} -p#{config['password']} -e 'CREATE database #{config['database']}'`

    tables.each do |table|
      `mysql -u #{config['user']} -p#{config['password']} #{config['database']} << #{table}`
    end

    if !File.exists?("#{Rails.root}/app/assets/order.sql")
      FileUtils.touch "#{Rails.root}/app/assets/order.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/test.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/test_result.sql")
      FileUtils.touch "#{Rails.root}/app/assets/test_result.sql"
    end

    if !File.exists?("#{Rails.root}/app/assets/order.sql")
      FileUtils.touch "#{Rails.root}/app/assets/order.sql"
    end

    Order.by_datetime_and_sending_facility.each do |order|

      #Insert order details
     "
      INSERT INTO order VALUES ()
    "

     "
      INSERT INTO test VALUES ()
    "

     "
      INSERT INTO test_trail VALUES ()
    "

    end
  end
end
