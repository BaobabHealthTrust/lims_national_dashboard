Rails.application.routes.draw do

   root 'home#home'

   get '/tests' => 'test#tests'

   get '/reports' => 'report#reports'

   get '/admin' => 'admin#index'

   get '/report_parameters' => 'report#report_parameters'

   get '/general_counts' => 'report#general_counts'

   post '/def' => 'report#def'

   get '/generic_report_data' => 'report#general_report_data'

   get '/login' => "user#login"

   get '/logout' => "user#logout"

   get '/verify_user' => "user#verify_user"

   get "user/index"

   post "report/exp"

   get "user/login"

   get "user/logout"

   get "user/create"

   get "user/edit"

   get "user/edit_user"

   post "user/verify_user"

   post "user/save"

   post "user/delete"

   post "user/save_edit"

   get "home/map_main"

	get "site/index"
	get "site/add_site"
	get "site/edit_site"
	get '/map' => "site#map"
	post "site/save_site"
	post "site/update_site"
	post "site/update_current_site"
	get "site/get_current_site"
  get "api/viral_load_stats"
  get "api/vl_result_by_npid"
  get "api/patient_lab_trail"
   get "api/pull_vl_by_id"

  get '/build_mysql_database' => 'test#build_mysql_database'
  post '/build_mysql_database' => 'test#build_mysql_database'
  get '/getStructure' => 'test#getStructure'
  get '/load_orders' => 'test#load_orders'
  get '/orders_total' => 'test#orders_total'

  get '/tests_total' => 'test#tests_total'
  get '/load_tests' => 'test#load_tests'

  get '/test_results_total' => 'test#test_results_total'
  get 'load_tests_results' => 'test#load_tests_results'

  get '/trails_total' => 'test#trails_total'
  get '/load_trails' => 'test#load_trails'

  get '/demo' => 'test#demo'
  get '/data' => 'test#demoStructure'
  get '/load_patients' => 'test#load_patients'



  post '/post_lab_catalog' => 'api#share_lab_catalog'
  post '/draw_un_drawn_sample' => 'api#drawn_un_drawn_sample'
  post '/add_test' => 'api#add_test_to_order'


  #apis 
  post '/lab_catalog' => 'api#retrieve_lab_catalog' 
  post '/push_lab_catalog' => 'api#share_lab_catalog'

  get '/view_validations' => 'report#view_validations'

  get '/validation_errors_list' => 'api#validation_errors_list'
  post '/validation_errors_list' => 'api#validation_errors_list'

  post '/capture_sample_dispatcher' => 'api#capture_sample_dispatcher'
end
