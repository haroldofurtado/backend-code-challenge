# frozen_string_literal: true

module DistributionPoints
  class CostsCalculationController < ApplicationController
    def show
      result = calculate_cost(fetch_permitted_params, fetch_routes)

      if result.success?
        render status: :ok, plain: String(result.success)
      else
        render status: :bad_request, nothing: true
      end
    end

    private

    def calculate_cost(permitted_params, routes)
      CalculateCost.new
                   .with_step_args(fetch_shortest_distance: [routes: routes])
                   .call(permitted_params)
    end

    def fetch_permitted_params
      params.permit(:origin, :destination, :weight)
    end

    def fetch_routes
      DistributionPoint.pluck(:origin, :destination, :distance)
    end
  end
end
