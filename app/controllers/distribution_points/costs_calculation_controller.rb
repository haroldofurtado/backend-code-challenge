# frozen_string_literal: true

module DistributionPoints
  class CostsCalculationController < ApplicationController
    def show
      result_for(CalculateShippingCost.new) do |result|
        if result.success?
          render status: :ok, plain: String(result.success)
        else
          failure = result.failure

          render status: failure == :not_found ? failure : :bad_request
        end
      end
    end

    private

    def result_for(transaction)
      routes_fetcher = -> { RoutesCache.new(Rails.cache).read }
      permitted_params = params.permit(:origin, :destination, :weight)

      yield transaction
        .with_step_args(fetch_routes: [routes_fetcher: routes_fetcher])
        .call(permitted_params)
    end
  end
end
