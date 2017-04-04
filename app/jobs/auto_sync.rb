require 'sync'

class AutoSync
  include SuckerPunch::Job
  workers 1

  def perform()
    begin
      configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]

      job_interval = configs['sync_interval_in_minutes'].to_f*30 rescue 30*60 #30 minutes
      job_interval = 30*60 if job_interval == 0

      if Rails.env == 'development'
        SuckerPunch.logger.info "Syncing records, Sync interval=#{job_interval}"
      end

      Sync.sync_all
      AutoSync.perform_in(job_interval)
    rescue
      AutoSync.perform_in(job_interval)
    end
  end
end
