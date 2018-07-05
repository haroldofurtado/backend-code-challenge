require 'rails_helper'

RSpec.describe DistributionPoints::Repository, type: :model do
  describe '#create_or_update!' do
    before { DistributionPoint.delete_all }

    def result_to(input)
      described_class.new.create_or_update! input
    end

    def output_of(input)
      result_to(input).output
    end

    context 'when there is no records to the origin and destination' do
      let(:input) { Hash[origin: ' A ', destination: 'B', distance: 5] }

      it { expect(result_to(input).action).to eq :create }
      it { expect(output_of(input)).to be_persisted }
      it { expect(output_of(input)).to be_an_instance_of DistributionPoint }
      it do
        expect(output_of(input).attributes).to include(
          'origin' => 'A', 'destination' => 'B', 'distance' => BigDecimal(5)
        )
      end
    end

    context 'when there is a record with the origin and destination' do
      let(:input) { Hash[origin: 'C', destination: 'D', distance: 123] }

      before { result_to(input) }

      it { expect(result_to(input).action).to eq :update }

      context 'and the same distance' do
        it 'avoids a record updating' do
          expect(output_of(input)).to eq 0
        end
      end

      context 'and the distance is different' do
        let(:input_with_new_distance) { input.merge(distance: 321) }

        it { expect(output_of(input_with_new_distance)).to eq 1 }
      end
    end

    context 'when receive invalid data' do
      it do
        result = double(failure?: true)

        allow(DistributionPoints::BaseSchema)
          .to receive(:new).and_return double(call: result)

        expect { described_class.new.create_or_update!({}) }
          .to raise_error Dry::Validation::InvalidSchemaError
      end
    end
  end
end
