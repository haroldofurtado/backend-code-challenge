# frozen_string_literal: true

module DistributionPoints
  class Repository
    Result = Struct.new(:action, :output)

    def initialize
      @model = ::DistributionPoint
      @base_schema = Schemas::ToSave.new
    end

    def create_or_update!(data)
      validate_result!(data) do |output|
        result_to :create, @model.create!(output)
      rescue ActiveRecord::RecordNotUnique
        result_to :update, update_by_origin_and_destination(output)
      end
    end

    private

    def result_to(action, output)
      Result.new(action, output).freeze
    end

    def validate_result!(data)
      result = @base_schema.call(data)

      raise Dry::Validation::InvalidSchemaError if result.failure?

      yield result.output
    end

    def update_by_origin_and_destination(output)
      scope = @model.by_origin_and_destination(output)

      distance = output.slice(:distance)

      scope.where.not(distance).update_all(distance)
    end
  end
end
