# frozen_string_literal: true

module DistributionPoints
  class CalculateCost
    include Dry::Transaction

    map  :params_to_cost_calculation_schema
    step :validate_schema_result
    try  :fetch_distance_and_weight, catch: IndexError
    map  :calculate

    def params_to_cost_calculation_schema(params)
      Schemas::ToCostCalculation.new.call(params.to_h)
    end

    def validate_schema_result(schema)
      return Success(schema) if schema.success?

      Failure(:invalid_params)
    end

    def fetch_distance_and_weight(schema)
      distance = DistributionPoint.pick_distance_by!(schema.output)

      [distance, schema[:weight]]
    end

    def calculate((distance, weight))
      distance.to_f * weight * 0.15
    end
  end
end
