require 'rails_helper'

RSpec.describe Types::FilledHash, type: :model do
  context 'with invalid input' do
    it 'raises a constraint error' do
      invalid_data = [nil, '', [], {}, 1]

      only_errors = invalid_data.all? do |data|
                      described_class[data]
                    rescue Dry::Types::ConstraintError
                      true
                    end

      expect(only_errors).to be_truthy
    end
  end

  context 'with valid input' do
    it 'returns the input as the output' do
      valid_data = [
        { a: 1 },
        { b: 2, c: 3}
      ]

      output = valid_data.map &described_class.method(:call)

      expect(output).to contain_exactly(*valid_data)
    end
  end
end
