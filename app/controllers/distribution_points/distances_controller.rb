# frozen_string_literal: true

module DistributionPoints
  class DistancesController < ApplicationController
    def create
      result = result_for(DeserializeParamsAndSave.new)

      render status: result.success? ? :no_content : :bad_request
    end

    private

    def result_for(transaction)
      routes_cache = RoutesCache.new(Rails.cache)
      serialized_params = request.body.read

      transaction.with_step_args(handle_routes_cache: [routes_cache])
                 .call(serialized_params)
    end
  end
end
