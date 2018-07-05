# frozen_string_literal: true

module Types
  include Dry::Types.module

  SerializedDistributionPoint = Types::Strict::String.constrained(
    format: /\A.+\s.+\s\d+(\.\d{1,2})?\z/
  )

  TrimmedString = Types::String.constructor do |str|
    str ? str.try(:strip).try { tap(&:chomp!) } : str
  end
end
