Rails.application.routes.draw do

   root 'home#home'

   get '/tests' => 'test#tests'

   get '/reports' => 'report#reports'

   get '/admin' => 'admin#index'

   get '/report_parameters' => 'report#report_parameters'

   get '/general_counts' => 'report#general_counts'

   get '/generic_report_data' => 'report#general_report_data'

   get '/login' => "user#login"

   get '/logout' => "user#logout"

   get '/verify_user' => "user#verify_user"

   get "user/index"

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

   get '/build_mysql_database' => 'test#build_mysql_database'
end
