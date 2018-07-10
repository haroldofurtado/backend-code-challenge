# frozen_string_literal: true

module DistributionPoints
  class CostsCalculationController < ApplicationController
    def show
      result = result_for(CalculateShippingCost.new)

      if result.success?
        render status: :ok, plain: String(result.success)
      else
        render status: result.failure == :not_found ? :not_found : :bad_request
      end
    end

    private

    def result_for(transaction)
      routes_fetcher = -> { RoutesCache.new(Rails.cache).read }
      permitted_params = params.permit(:origin, :destination, :weight)

      transaction.with_step_args(fetch_routes: [routes_fetcher: routes_fetcher])
                 .call(permitted_params)
    end
  end
end
