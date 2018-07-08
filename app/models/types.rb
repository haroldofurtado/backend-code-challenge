# frozen_string_literal: true

module Types
  include Dry::Types.module

  module DistributionPoint
    Serialized = Types::Strict::String.constrained(
      format: /\A.+\s.+\s\d+(\.\d{1,2})?\z/
    )
  end

  TrimmedString = Types::String.constructor do |str|
    str.try(:strip).try { tap(&:chomp!) }
  end

  TrimmedStringWithNormalizedWhitespace = Types::String.constructor do |value|
    TrimmedString[value].try { tap { |str| str.gsub!(/\s+/, ' ') } }
  end

  FilledHash = Types::Hash.constrained(filled: true)
end
