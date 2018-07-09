# frozen_string_literal: true

module DistributionPoints
  class DistancesController < ApplicationController
    def create
      result = deserialize_params_and_save

      render status: result.success? ? :no_content : :bad_request
    end

    private

    def deserialize_params_and_save
      DeserializeParamsAndSave
        .new
        .with_step_args(delete_routes_cache: [RoutesCache.new(Rails.cache)])
        .call(request.body.read)
    end
  end
end
