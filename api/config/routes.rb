Rails.application.routes.draw do
  scope :api do
    post 'signup', to: 'users#create'
    post 'login', to: 'sessions#create'

    resources :authors
    resources :materials do
      collection do
        get :search
      end
    end
  end

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
end
