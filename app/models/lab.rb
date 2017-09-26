require 'couchrest_model'

class Lab < CouchRest::Model::Base

	use_database "labs"

	property :lab_cat, {}
	property :_id, String
	property :samples, {}

	def self.push_lab_cat_log(cat_log)
	    data = cat_log
	    keys = cat_log.keys
	    keys.each do |k|
	      next if k == "controller" or k == "action" or k == "api"
	      sample_keys = data[k][0].keys	     
	        t =  Lab.new()
	        t._id = k
	        t.lab_cat =  data[k][0]
	        t.samples =  data[k][0].keys
	        t.save()
	    end
   
    end

	design do 
		view  :by_samples
		view  :by__id
	end
	

end
