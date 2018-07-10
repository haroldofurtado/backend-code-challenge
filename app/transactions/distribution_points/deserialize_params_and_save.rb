# frozen_string_literal: true

module DistributionPoints
  class DeserializeParamsAndSave
    include Dry::Transaction

    PARSING_KEYS = %i[origin destination distance].freeze

    try :validate_serialized_params, catch: Dry::Types::ConstraintError
    map :parse_distribution_point
    try :create_or_update, catch: Dry::Validation::InvalidSchemaError
    tee :handle_routes_cache

    def validate_serialized_params(input)
      Types::DistributionPoint::SerializedParams[
        Types::TrimmedStringWithNormalizedWhitespace[input]
      ]
    end

    def parse_distribution_point(serialized_params)
      Hash[PARSING_KEYS.zip(serialized_params.split)]
    end

    def create_or_update(distribution_point_params)
      RepositoryCommands::CreateOrUpdate.new.call(distribution_point_params)
    end

    def handle_routes_cache(repository_result, routes_cache)
      routes_cache.delete if repository_result.database_was_touched?
    end
  end
end
