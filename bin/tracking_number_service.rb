module TrackingNumberService
  def self.generate_tracking_number(date = Date.today)
    configs = YAML.load_file "#{Rails.root}/config/application.yml"
    site_code = configs['site_code']
    file  = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}

    if file[date.strftime("%Y%m%d")].blank?
      file  = {date.strftime("%Y%m%d") => 1}
      save_counter(date)
    end

    todate= date.strftime("%Y%m%d")
    year  =   date.strftime("%Y%m%d").to_s.slice(2..3)
    month =  date.strftime("%m")
    day   =    date.strftime("%d")

    counter = file[todate]
    value = counter.to_s.rjust(3, "0")
    tracking_number = "X#{site_code}#{year}#{get_month(month)}#{get_day(day)}#{value}"
    save_counter(date)

    return tracking_number
  end

  def self.save_counter(date=Date.today)
    file = JSON.parse(File.read("#{Rails.root}/public/tracker.json")) rescue {}
    todate = date.strftime("%Y%m%d")

    counter = file[todate]
    counter = counter.to_i + 1
    file[todate] = counter
    File.open("#{Rails.root}/public/tracker.json", 'w') {|f|

      f.write(file.to_json) }
  end

  def self.get_month(month)

    case month

      when "01"
        return "1"
      when "02"
        return "2"
      when "03"
        return "3"
      when "04"
        return "4"
      when "05"
        return "5"
      when "06"
        return "6"
      when "07"
        return "7"
      when "08"
        return "8"
      when "09"
        return "9"
      when "10"
        return "A"
      when "11"
        return "B"
      when "12"
        return "C"
    end

  end

  def self.get_day(day)

    case day

      when "01"
        return "1"
      when "02"
        return "2"
      when "03"
        return "3"
      when "04"
        return "4"
      when "05"
        return "5"
      when "06"
        return "6"
      when "07"
        return "7"
      when "08"
        return "8"
      when "09"
        return "9"
      when "10"
        return "A"
      when "11"
        return "B"
      when "12"
        return "C"
      when "13"
        return "E"
      when "14"
        return "F"
      when "15"
        return "G"
      when "16"
        return "H"
      when "17"
        return "Y"
      when "18"
        return "J"
      when "19"
        return "K"
      when "20"
        return "Z"
      when "21"
        return "M"
      when "22"
        return "N"
      when "23"
        return "O"
      when "24"
        return "P"
      when "25"
        return "Q"
      when "26"
        return "R"
      when "27"
        return "S"
      when "28"
        return "T"
      when "29"
        return "V"
      when "30"
        return "W"
      when "31"
        return "X"
    end

  end
end
