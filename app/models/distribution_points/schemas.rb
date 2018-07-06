# frozen_string_literal: true

module DistributionPoints
  module Schemas

    class Params < Dry::Validation::Schema::Params
      configure { |config| config.type_specs = true }
    end

    private_constant :Params

    BASE_DEFINITIONS = <<~RUBY
      required(:origin, Types::TrimmedString).filled(:str?, min_size?: 1)

      required(:destination, Types::TrimmedString).filled(:str?, min_size?: 1)

      rule(different_points: %i[origin destination]) do |orig, dest|
        orig.not_eql? value(:destination)
      end
    RUBY

    private_constant :BASE_DEFINITIONS

    class ToSave < Params
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        define! do
          #{BASE_DEFINITIONS}

          required(:distance, Types::Coercible::Decimal).filled(
            :decimal?, gt?: 0, lteq?: 100_000
          )
        end
      RUBY
    end

    class ToCostCalculation < Params
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        define! do
          #{BASE_DEFINITIONS}

          required(:weight, Types::Coercible::Int).filled(
            :int?, gt?: 0, lteq?: 50
          )
        end
      RUBY
    end

  end
end
