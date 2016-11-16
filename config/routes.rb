Rails.application.routes.draw do

   root 'home#home'

   get '/tests' => 'test#tests'

   get '/reports' => 'report#reports'

   get '/admin' => 'admin#index'

   get '/report_parameters' => 'report#report_parameters'

   get '/general_counts' => 'report#general_counts'

   get '/generic_report_data' => 'report#general_report_data'


end
