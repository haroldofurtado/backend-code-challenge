# frozen_string_literal: true

module DistributionPoints
  class DeserializeParamsAndSave
    include Dry::Transaction

    PARSING_KEYS = %i[origin destination distance].freeze

    ALLOWED_ERRORS_TO_SAVE = [
      Dry::Validation::InvalidSchemaError,
      ActiveRecord::RecordNotUnique
    ].freeze

    try :validate_serialized_params, catch: Dry::Types::ConstraintError
    map :parse_distribution_point
    try :save, catch: ALLOWED_ERRORS_TO_SAVE

    def validate_serialized_params(input)
      Types::DistributionPoint::SerializedParams[
        Types::TrimmedStringWithNormalizedWhitespace[input]
      ]
    end

    def parse_distribution_point(serialized_params)
      Hash[PARSING_KEYS.zip(serialized_params.split)]
    end

    def save(distribution_point_params)
      Repository.new.create_or_update!(distribution_point_params)
    end
  end
end
