# frozen_string_literal: true

module DistributionPoints
  class BaseSchema < Dry::Validation::Schema::Params
    configure do |config|
      config.type_specs = true
    end

    define! do
      required(:origin, Types::TrimmedString).filled(:str?, min_size?: 1)

      required(:destination, Types::TrimmedString).filled(:str?, min_size?: 1)

      required(:distance, Types::Coercible::Decimal).filled(
        :decimal?, gt?: 0, lteq?: 100_000
      )

      rule(different_points: %i[origin destination]) do |orig, dest|
        orig.not_eql? value(:destination)
      end
    end
  end
end
