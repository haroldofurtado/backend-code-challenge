# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/cost', to: 'distribution_points/costs_calculation#show',
               as: :distribution_points_cost_calculation

  post '/distance', to: 'distribution_points/distances#create',
                    as: :distribution_points_distance
end
