# frozen_string_literal: true

module DistributionPoints
  module SchemaValidation
    extend ActiveSupport::Concern

    included do
      validate :with_schema_validation_to_save
    end

    private

    def with_schema_validation_to_save
      result = Schemas::ToSave.new.call(
        attributes.except('id', 'created_at', 'updated_at').symbolize_keys
      )

      return if result.success?

      result.errors.each { |attribute, error| errors.add(attribute, error) }
    end
  end
end
