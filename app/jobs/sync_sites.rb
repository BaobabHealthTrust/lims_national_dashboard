require 'sync'
require 'net/ping'
require 'socket'
require 'open3'

class SyncSites
    include SuckerPunch::Job
    workers 1   

   

    def perform()
        
        begin

            Sync.sync_all
           
            SyncSites.perform_in(0)
        rescue
            SyncSites.perform_in(0)
        end
    end
    
end





