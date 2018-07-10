# frozen_string_literal: true

class DistributionPoint < ApplicationRecord
  include DistributionPoints::WithParamsSchemaValidation

  scope :by_origin_and_destination, ->(conditions) do
    where Types::FilledHash[conditions].slice(:origin, :destination)
  end
end
