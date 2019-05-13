require 'sidekiq/web'

Rails.application.routes.draw do

  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == ['admin', 'admin']
  end

  mount Sidekiq::Web => '/sidekiq'
  
  resources :apidocs, only: :index

  ### API ROUTES ###
  namespace :api do
    namespace :v1 do
      resources :chat_applications, except: [:destroy, :edit], param: :token do
        resources :chats, except: [:destroy, :edit, :update], param: :number do
          resources :messages, except: [:destroy, :edit], param: :number
        end
      end
    end
  end
end
