# frozen_string_literal: true

module DistributionPoints
  class Repository
    Result = Struct.new(:action, :output)

    def initialize
      @model = ::DistributionPoint
      @base_schema = Schemas::ToSave.new
    end

    def create_or_update!(data)
      output = fetch_schema_output!(data)

      result_with :create, @model.create!(output)
    rescue ActiveRecord::RecordNotUnique
      result_with :update, update_by_origin_and_destination(output)
    end

    private

    def result_with(action, output)
      Result.new(action, output).freeze
    end

    def fetch_schema_output!(data)
      result = @base_schema.call(data)

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
