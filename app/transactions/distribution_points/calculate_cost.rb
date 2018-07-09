# frozen_string_literal: true

module DistributionPoints
  class CalculateCost
    include Dry::Transaction

    SHIPPING_TAX = 0.15

    private_constant :SHIPPING_TAX

    map  :params_to_cost_calculation_schema
    step :validate_schema_result
    try  :build_shortest_path_finder, catch: Dry::Types::ConstraintError
    step :fetch_shortest_distance
    map  :calculate

    def params_to_cost_calculation_schema(params)
      Schemas::ToCostCalculation.new.call(params.to_h)
    end

    def validate_schema_result(schema)
      return Success(schema) if schema.success?

      Failure(:invalid_params)
    end

    def build_shortest_path_finder(schema, routes:)
      algorithm = Dijkstra.new schema[:origin],
                               schema[:destination],
                               Types::FilledArray[routes]

      [algorithm, schema]
    end

    def fetch_shortest_distance((algorithm, schema))
      Success [Types::Numeric[algorithm.cost], schema]
    rescue Dry::Types::ConstraintError
      Failure(:not_found)
    end

    def calculate((distance, schema))
      distance.to_f * schema[:weight] * SHIPPING_TAX
    end
  end
end
