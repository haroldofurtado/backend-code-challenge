# frozen_string_literal: true

module DistributionPoints
  module ParamsSchema

    class Base < Dry::Validation::Schema::Params
      configure { |config| config.type_specs = true }
    end

    # Workaround because of an issue with coercion when reusing schemas.
    # https://github.com/dry-rb/dry-validation/issues/340
    BASE_DEFINITIONS = <<~RUBY
      required(:origin, Types::TrimmedString).filled(:str?, min_size?: 1)

      required(:destination, Types::TrimmedString).filled(:str?, min_size?: 1)

      rule(different_points: %i[origin destination]) do |orig, dest|
        orig.not_eql? value(:destination)
      end
    RUBY

    class ToSave < Base
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        define! do
          #{BASE_DEFINITIONS}
          required(:distance, Types::Coercible::Decimal).filled(
            :decimal?, gt?: 0, lteq?: 100_000
          )
        end
      RUBY
    end

    class ToCalculateShippingCost < Base
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        define! do
          #{BASE_DEFINITIONS}
          required(:weight, Types::Coercible::Int).filled(
            :int?, gt?: 0, lteq?: 50
          )
        end
      RUBY
    end

    private_constant :Base, :BASE_DEFINITIONS

  end
end
