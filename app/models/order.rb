require 'couchrest_model'

class Order < CouchRest::Model::Base
	
  def tracking_number
    self['_id']
  end

  def national_id
    self['patient']['national_patient_id']
  end

  def results
    r = {}
    result_names = self['results'].keys
    result_names.each do |rn |
      ts = self['results'][rn].keys.last
      next if ts.blank?
      r[rn] =  self['results'][rn][ts]
    end
    r
  end

  def status
    rst = self.results.first[1]['test_status'] rescue self['status']
    rst || self['status']
  end

  design do
    view :generic,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['date_time']]);
                    }
                }"

    view :by_datetime_and_sending_facility,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['sending_facility'] + '_' + doc['date_time']]);
                    }
                }"

    view :by_datetime_and_district,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['district'] + '_' + doc['date_time']]);
                    }
                }"

    view :by_datetime_and_receiving_facility,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['receiving_facility'] + '_' + doc['date_time']]);
                    }
                }"

    view :by_datetime_and_sample_type,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['sample_type'] + '_' + doc['date_time']]);
                    }
                }"

    view :by_patient_name,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['patient']['first_name'].trim(), doc['patient']['middle_name'].trim(), doc['patient']['last_name'].trim()]);
                    }
                }"
  end

end
