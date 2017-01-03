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
      ts = self['results'][rn].keys
      ts.each do |t|
        ts = ts - [t] if self['results'][rn][t]['results'].blank?
      end
      ts = ts.max
      next if ts.blank?
      r[rn] =  self['results'][rn][ts]['results'] rescue {}
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
                      emit([doc['sending_facility'].trim() + '_' + doc['date_time']]);
                    }
                }"

    view :by_datetime_and_district,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['district'].trim() + '_' + doc['date_time']]);
                    }
                }"

    view :by_datetime_and_receiving_facility,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['receiving_facility'].trim() + '_' + doc['date_time']]);
                    }
                }"
    view :by_datetime_and_sample_type,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['sample_type'].trim() + '_' + doc['date_time']]);
                    }
                }"

    view :by_patient_name,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      emit([doc['patient']['first_name'].trim(), doc['patient']['middle_name'].trim(), doc['patient']['last_name'].trim()]);
                    }
                }"

    view :by_test_type,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      var test_types = doc['test_types'];
                      for(i in test_types){
                        emit([test_types[i]]);
                      }
                    }
                }"

    view :by_datetime_and_test_type,
         :map => "function(doc) {
                    if (doc['_id'].match(/^X/)) {
                      var test_types = doc['test_types'];
                      for(i in test_types){
                        emit([test_types[i] + '_' + doc['date_time']]);
                      }
                    }
                }"

    view :by_test_type_and_status_and_datetime,
         :map => "function(doc){
                    if (doc['_id'].match(/^X/)) {
                      var results = doc['results'];
                      var test_types = doc['test_types'];
                      for(var i in test_types){

                        if(typeof(results[test_types[i]]) != 'undefined' ){
                          var cur_result = results[test_types[i]];
                          var tss = Object.keys(cur_result);
                          var ts = tss[tss.length - 1];

                          if(typeof(cur_result[ts]) != 'undefined'){
                            var status = doc['status'].toLowerCase().trim();
                            if(status != 'rejected' && status != 'voided' && status != 'not done'){
                              status = cur_result[ts]['test_status'].toLowerCase().trim();
                            }
                            emit([doc['sending_facility'].toLowerCase() + '_' + test_types[i].toLowerCase() + '_' + status + '_' + doc['date_time']]);
                          }
                        }
                      }
                    }
                }"

    view :by_national_id_and_datetime,
         :map => "function(doc){
                    if (doc['_id'].match(/^X/)) {
                       if(typeof(doc['patient']['national_patient_id']) != 'undefined' && doc['patient']['national_patient_id'].trim() != ''){
                          emit([doc['patient']['national_patient_id'].replace('$', '') + '_' + doc['date_time']]);
                       }
                    }
                }"
  end

end
