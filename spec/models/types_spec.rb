require 'rails_helper'

RSpec.describe Types, type: :model do
  it do
    expect(described_class)
      .to be_a_kind_of Dry::Types::BuilderMethods
  end

  describe Types::SerializedDistributionPoint do
    context 'with invalid input' do
      it 'raises a constraint error' do
        invalid_data = [nil, '', 'A', 'A B', 'A B 1.']

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
          'A B 1',
          'C D 2.1',
          'E F 10.1',
          'G H 10.11',
        ]

        output = valid_data.map{ |data| described_class[data] }

        expect(output).to contain_exactly(*valid_data)
      end
    end
  end
end
