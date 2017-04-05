#This file is used to sync data birectional from and to all enabled sites
#Kenneth Kapundi@3/March/2017

require 'net/ping'
require 'socket'
require 'open3'

class Sync

  def self.sync_all
    sites = Site.by_enabled.key(true)
    configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    local_ip = self.local_ip

    databases = [
        configs['prefix'] + "_" + configs["suffix"],
        configs['prefix'] + "_sites_" + configs["suffix"]
    ]

    sites.each do |site|
      next if local_ip == site.host

      if self.up?(site.host)
        databases.each do |database|
          remote_address = "http://#{configs['username']}:#{configs['password']}@#{site.host}:#{site.port}/#{database}"
          local_address = "http://#{configs['username']}:#{configs['password']}@#{local_ip}:#{configs['port']}/#{database}"

          `curl -X POST  http://127.0.0.1:5984/_replicate -d '{"source":"#{remote_address}","target":"#{local_address}", "continuous":true}' -H "Content-Type: application/json"`

          if (configs['bidirectional_sync'].to_s rescue nil) == "true"
            `curl -X POST  http://127.0.0.1:5984/_replicate -d '{"source":"#{local_address}","target":"#{remote_address}", "continuous":true}' -H "Content-Type: application/json"`
          end
        end
      end
    end
  end

  def self.up?(host, port=5984)
    a, b, c = Open3.capture3("nc -vw 1 #{host} #{port}")
    b.scan(/succeeded/).length > 0
  end

  def self.local_ip
    self.private_ipv4.ip_address rescue (self.public_ipv4.ip_address rescue nil)
  end

  def self.private_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  end

  def self.public_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
  end
end

