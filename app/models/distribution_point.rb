# frozen_string_literal: true

class DistributionPoint < ApplicationRecord
  validate :with_schema_validation_to_save

  scope :by_origin_and_destination, ->(conditions) do
    where Types::FilledHash[conditions].slice(:origin, :destination)
  end

  def self.pick_distance_by!(conditions)
    by_origin_and_destination(conditions).limit(1).pluck(:distance).fetch(0)
  end

  def with_schema_validation_to_save
    result = DistributionPoints::Schemas::ToSave.new.call(
      attributes.except('id', 'created_at', 'updated_at').symbolize_keys
    )

    return if result.success?

    result.errors.each { |attribute, error| errors.add(attribute, error) }
  end
end
