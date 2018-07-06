# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/distance', to: 'distribution_points/distances#create',
                    as: :distribution_points_distance
end
