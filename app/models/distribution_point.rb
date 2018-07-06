# frozen_string_literal: true

class DistributionPoint < ApplicationRecord
  include DistributionPoints::SchemaValidation

  scope :by_origin_and_destination, ->(conditions) do
    where Types::FilledHash[conditions].slice(:origin, :destination)
  end

  def self.pick_distance_by!(conditions)
    by_origin_and_destination(conditions).limit(1).pluck(:distance).fetch(0)
  end
end
