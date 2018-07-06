# frozen_string_literal: true

module Types
  include Dry::Types.module

  SerializedDistributionPoint = Types::Strict::String.constrained(
    format: /\A.+\s.+\s\d+(\.\d{1,2})?\z/
  )

  TrimmedString = Types::String.constructor do |str|
    str ? str.try(:strip).try { tap(&:chomp!) } : str
  end

  TrimmedStringWithNormalizedWhitespace = Types::String.constructor do |value|
    TrimmedString[value].try { tap { |str| str.gsub!(/\s+/, ' ') } }
  end

  FilledHash = Types::Strict::Hash.constrained(filled: true)
end
