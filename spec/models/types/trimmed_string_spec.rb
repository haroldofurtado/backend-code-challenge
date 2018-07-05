require 'rails_helper'

RSpec.describe Types::TrimmedString, type: :model do
  context 'with invalid input' do
    it 'returns nil' do
      invalid_data = [nil, [], 1]

      results = invalid_data.map &described_class.method(:call)

      expect(results).to all( be_nil )
    end
  end

  context 'with valid input' do
    it 'returns a trimmed output' do
      valid_data = [
        ' 1', ' 2 ', " a\n", " b\n\r",
      ]

      output = valid_data.map &described_class.method(:call)

      expect(output).to contain_exactly('1', '2', 'a', 'b')
    end
  end
end
