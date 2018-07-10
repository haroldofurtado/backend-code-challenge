# frozen_string_literal: true

module DistributionPoints
  module RepositoryCommands

    class CreateOrUpdate
      Result = Struct.new(:action, :output) do
        def database_was_touched?
          action == :create || happened_an_update?
        end

        def happened_an_update?
          action == :update && output == 1
        end
      end

      def initialize
        @model = ::DistributionPoint
        @params_schema = ParamsSchema::ToSave.new
      end

      def call(data)
        output = fetch_params_schema_output!(data)

        Result.new :create, @model.create!(output)
      rescue ActiveRecord::RecordNotUnique
        Result.new :update, update_by_origin_and_destination(output)
      end

      private

      def fetch_params_schema_output!(data)
        result = @params_schema.call(data)

        raise Dry::Validation::InvalidSchemaError if result.failure?

        result.output
      end

      def update_by_origin_and_destination(output)
        scope = @model.by_origin_and_destination(output)

        distance = output.slice(:distance)

        scope.where.not(distance).update_all(distance)
      end
    end

  end
end
