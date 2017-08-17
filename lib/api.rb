module API
  def self.stats(start_date="1917-05-25 08:57:06 UTC".to_time, end_date=Time.now)
    result = {}
    configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    rules = []

    (Dir.glob("#{configs['validation_rules_dir']}/*") || []).each do |file|
      rules << file.split(/\//).last.split(/\.js/).first rescue next
    end

    rules.each do |rule|
      result[rule] = {} if result[rule].blank?
      start_key = "#{rule}_#{start_date.strftime("%Y%m%d%H%M%S")}"
      end_key   = "#{rule}_#{end_date.strftime("%Y%m%d%H%M%S")}"

      errors = Order.by_error_category_and_datetime_my_site.startkey([start_key]).endkey([end_key])
      errors.each do |error|
        result[rule][error['status']] =  0 if result[rule][error['status']].blank?
        result[rule][error['status']] += 1
      end
    end

    result
  end

  def self.stats_with_options(start_date="1917-05-25 08:57:06 UTC".to_time, end_date=Time.now, options = {})
    result = {}
    configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    rules = []

    (Dir.glob("#{configs['validation_rules_dir']}/*") || []).each do |file|
      rules << file.split(/\//).last.split(/\.js/).first rescue next
    end

    rules.each do |rule|
      result[rule] = {} if result[rule].blank?
      start_key = "#{rule}_#{start_date.strftime("%Y%m%d%H%M%S")}"
      end_key   = "#{rule}_#{end_date.strftime("%Y%m%d%H%M%S")}"

      errors = Order.by_error_category_and_datetime_my_site.startkey([start_key]).endkey([end_key])
      errors.each do |error|
        match = true
        options.each do | k , v |
            if error[k] != v
              match = false
              next
            end
        end

        next if match == false

        result[rule][error['status']] =  0 if result[rule][error['status']].blank?
        result[rule][error['status']] += 1
      end
    end

    result
  end

  def self.admin_stats(start_date="1917-05-25 08:57:06 UTC".to_time, end_date=Time.now)
    result = {}
    configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    rules = []

    (Dir.glob("#{configs['validation_rules_dir']}/*") || []).each do |file|
      rules << file.split(/\//).last.split(/\.js/).first rescue next
    end

    rules.each do |rule|
      result[rule] = {} if result[rule].blank?
      start_key = "#{rule}_#{start_date.strftime("%Y%m%d%H%M%S")}"
      end_key   = "#{rule}_#{end_date.strftime("%Y%m%d%H%M%S")}"

      errors = Order.by_error_category_and_datetime.startkey([start_key]).endkey([end_key])
      errors.each do |error|
        result[rule][error['status']] =  0 if result[rule][error['status']].blank?
        result[rule][error['status']] += 1
      end
    end

    result
  end

  def self.admin_stats_with_options(start_date="1917-05-25 08:57:06 UTC".to_time, end_date=Time.now, options = {})
    result = {}
    configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    rules = []

    (Dir.glob("#{configs['validation_rules_dir']}/*") || []).each do |file|
      rules << file.split(/\//).last.split(/\.js/).first rescue next
    end

    rules.each do |rule|
      result[rule] = {} if result[rule].blank?

      start_key = "#{rule}_#{start_date.strftime("%Y%m%d%H%M%S")}"
      end_key   = "#{rule}_#{end_date.strftime("%Y%m%d%H%M%S")}"

      errors = Order.by_error_category_and_datetime.startkey([start_key]).endkey([end_key])
      errors.each do |error|
        match = true
        options.each do | k , v |
          if error[k] != v
            match = false
            next
          end
        end

        next if match == false

        result[rule][error['status']] =  0 if result[rule][error['status']].blank?
        result[rule][error['status']] += 1
      end
    end

    result
  end
end

