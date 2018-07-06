# frozen_string_literal: true

class DistributionPoint < ApplicationRecord
  validate :with_schema_validation_to_save

  def with_schema_validation_to_save
    result = DistributionPoints::Schemas::ToSave.new.call(
      attributes.except('id', 'created_at', 'updated_at').symbolize_keys
    )

    return if result.success?

    result.errors.each { |attribute, error| errors.add(attribute, error) }
  end
end
