require 'couchrest_model'

class Lab < CouchRest::Model::Base

	use_database "labs"

	property :tests, {}
	property :_id, String
	property :samples, {}
	property :test_panels, {}
	property :test_short_names,{}

	def self.push_lab_cat_log(cat_log)
	    data = cat_log
	    keys = ""
	    samples = ""
	    da = data.each
	    data.each do |e|
	    	next if e[0] == "controller" || e[0] == "action" || e[0] == "api"
	    	lab_name = e[0]
	    	samples = e[1]["samples"]
	    	tests = e[1]["tests"]
	    	panels = e[1]["test_panels"]
	    	short_names = e[1]["test_short_names"]

	    	t =  Lab.new()
	        t._id = lab_name
	        t.tests =  tests
	        t.samples =  samples
	        t.test_panels = panels
	        t.test_short_names = short_names
	        t.save()
	    end

   
    end

	design do 
		view  :by_samples
		view  :by__id
		view  :by_test_panels
		view  :by_test_short_names
	end
	

end
