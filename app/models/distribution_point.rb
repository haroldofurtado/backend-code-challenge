# frozen_string_literal: true

class DistributionPoint < ApplicationRecord
  validate :with_params_schema_validation

  def with_params_schema_validation
    result = DistributionPoints::BaseSchema.new.call(
      attributes.except('id', 'created_at', 'updated_at').symbolize_keys
    )

    return if result.success?

    result.errors.each { |attribute, error| errors.add(attribute, error) }
  end
end
