# frozen_string_literal: true

module DistributionPoints
  class CostsCalculationController < ApplicationController
    def show
      result = calculate_cost(fetch_permitted_params, routes_fetcher)

      if result.success?
        render status: :ok, plain: String(result.success)
      else
        render status: result.failure == :not_found ? :not_found : :bad_request
      end
    end

    private

    def calculate_cost(permitted_params, routes)
      CalculateCost.new
                   .with_step_args(build_shortest_path_finder: [routes: routes])
                   .call(permitted_params)
    end

    def fetch_permitted_params
      params.permit(:origin, :destination, :weight)
    end

    def routes_fetcher
      -> { DistributionPoint.pluck(:origin, :destination, :distance) }
    end
  end
end
