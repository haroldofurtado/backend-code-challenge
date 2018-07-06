# frozen_string_literal: true

module DistributionPoints
  class CalculateCost
    include Dry::Transaction

    step :validate_params
    try :fetch_distance_and_weight, catch: IndexError
    map :calculate

    def validate_params(params)
      result = Schemas::ToCostCalculation.new.call(params.to_h)

      result.success? ? Success(result) : Failure(:invalid_params)
    end

    def fetch_distance_and_weight(schema)
      [fetch_distance!(schema), schema[:weight]]
    end

    def calculate((distance, weight))
      distance.to_f * weight * 0.15
    end

    def fetch_distance!(schema)
      DistributionPoint.pick_distance_by!(schema.output)
    end
  end
end
