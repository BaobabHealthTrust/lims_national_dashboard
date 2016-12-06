class Site < CouchRest::Model::Base
  use_database "sites"

  cattr_accessor :current

  property :name, String
  property :description, String
  property :host, String
  property :port, Integer
  property :code, String
  property :x, String
  property :y, String
  property :region, String
  property :enabled, TrueClass, :default => false
  property :creator, String

  timestamps!

  design do
    view :by_enabled,
         :map => "function(doc) {
                     emit(doc['enabled']);
                }"
    view :by_name,
         :map => "function(doc) {
                     emit(doc['name']);
                }"
  end

  def self.alerts
    alerts = {"urgent" => [],
              "average" => [],
              "normal" => []
    }

    Observation.sorted_sites_failures.each do |site, errors|

       if errors > 100
         alerts["urgent"] << site
       elsif errors > 0
          alerts["average"] << site
       else
         alerts["normal"] << site
       end
    end

    alerts["normal"] = alerts["normal"] +  (Site.by_enabled.key(true).map(&:name)   - alerts.values.flatten)

    return alerts
  end

  def self.add_site(name,code, host, port, region, x, y)
    site = Site.new({:name => name, :code => code, :host => host,:port =>port, :region => region,:x =>  x, :y => y})

    if site.save
      return ["Site successfully saved", true]
    else
      return ["Site could not be added", nil]
    end
  end

  def add_creator
    if !self.creator
      self.creator = User.current.id
    end
  end

  def self.update_site(old_name,name,code, host, port, region, x, y)
    site = Site.by_name.key(old_name).first
    site.name = name
    site.code = code
    site.host = host
    site.port = port
    site.region = region
    site.x =  x
    site.y = y
    if site.save
      return ["Site details successfully updated", true]
    else
      return ["Site details could not be updated", nil]
    end
  end
end
