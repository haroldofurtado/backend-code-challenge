# frozen_string_literal: true

module DistributionPoints
  class DeserializeAndSave
    include Dry::Transaction

    PARSING_KEYS = %i[origin destination distance].freeze

    try :validate_serialized_data, catch: Dry::Types::ConstraintError
    map :parse_distribution_point
    try :save, catch: [
      Dry::Validation::InvalidSchemaError,
      ActiveRecord::RecordNotUnique
    ]

    def validate_serialized_data(input)
      Types::DistributionPoint::Serialized[
        Types::TrimmedStringWithNormalizedWhitespace[input]
      ]
    end

    def parse_distribution_point(input)
      Hash[PARSING_KEYS.zip(input.split)]
    end

    def save(input)
      Repository.new.create_or_update!(input)
    end
  end
end
