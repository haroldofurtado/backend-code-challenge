# frozen_string_literal: true

module DistributionPoints
  class CalculateShippingCost
    include Dry::Transaction

    SHIPPING_TAX = 0.15

    map  :schema_to_calculate_shipping_cost
    step :validate_schema_result
    try  :fetch_routes, catch: NoMethodError
    map  :fetch_shortest_distance
    step :calculate_shipping_cost

    def schema_to_calculate_shipping_cost(params)
      ParamsSchema::ToCalculateShippingCost.new.call(params.to_h)
    end

    def validate_schema_result(schema)
      return Success(schema) if schema.success?

      Failure(:invalid_params)
    end

    def fetch_routes(schema, routes_fetcher:)
      routes = routes_fetcher.try!(:call)

      [schema, Types::FilledArray[routes]]
    end

    def fetch_shortest_distance((schema, routes))
      distance =
        Dijkstra.new(schema[:origin], schema[:destination], routes).cost

      [schema, distance]
    end

    def calculate_shipping_cost((schema, distance))
      return Failure(:not_found) unless Types::Numeric.valid?(distance)

      Success(distance.to_f * schema[:weight] * SHIPPING_TAX)
    end
  end
end
