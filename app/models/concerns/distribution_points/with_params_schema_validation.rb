# frozen_string_literal: true

module DistributionPoints
  module WithParamsSchemaValidation
    extend ActiveSupport::Concern

    included do
      validate :with_params_schema_validation
    end

    private

    def with_params_schema_validation
      result = ParamsSchema::ToSave.new.call(
        attributes.except('id', 'created_at', 'updated_at').symbolize_keys
      )

      return if result.success?

      result.errors.each { |attribute, error| errors.add(attribute, error) }
    end
  end
end
