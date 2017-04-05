namespace :dashboard do
  desc "TODO"
  task jobs: :environment do
    require Rails.root.join('bin','jobs.rb')
  end
end
