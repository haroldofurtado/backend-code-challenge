# frozen_string_literal: true

module DistributionPoints
  class DistancesController < ApplicationController
    def create
      result_for(DeserializeParamsAndSave.new) do |result|
        render status: result.success? ? :no_content : :bad_request
      end
    end

    private

    def result_for(transaction)
      routes_cache = RoutesCache.new(Rails.cache)
      serialized_params = request.body.read

      yield transaction
        .with_step_args(handle_routes_cache: [routes_cache])
        .call(serialized_params)
    end
  end
end
