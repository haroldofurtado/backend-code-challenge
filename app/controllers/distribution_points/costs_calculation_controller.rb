# frozen_string_literal: true

module DistributionPoints
  class CostsCalculationController < ApplicationController
    def show
      result = CalculateCost.new.call(permitted_params_to_show)

      if result.success?
        result.bind { |value| render status: :ok, plain: String(value) }
      else
        render status: :bad_request, nothing: true
      end
    end

    private

    def permitted_params_to_show
      params.permit(:origin, :destination, :weight)
    end
  end
end
