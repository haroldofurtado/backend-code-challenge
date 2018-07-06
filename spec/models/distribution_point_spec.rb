require 'rails_helper'

RSpec.describe DistributionPoint, type: :model do
  def create(orig, dest, dist)
    DistributionPoint.create(origin: orig, destination: dest, distance: dist)
  end

  context 'validations' do
    let(:attributes) { Hash[origin: orig, destination: dest, distance: dist] }

    subject { described_class.new(attributes) }

    context 'with valid data' do
      let(:orig) { 'A' }
      let(:dest) { " B\n\r" }
      let(:dist) { 100_000 }

      it { is_expected.to be_valid }
    end

    context 'with invalid data' do
      let(:orig) { '' }
      let(:dest) { " \n\r" }
      let(:dist) { '1.' }

      it { is_expected.to_not be_valid }

      it { expect(subject.tap(&:valid?).errors).to include :origin }
      it { expect(subject.tap(&:valid?).errors).to include :destination }
      it { expect(subject.tap(&:valid?).errors).to include :distance }
    end

    it 'invokes DistributionPoints::Schemas::ToSave' do
      data = { origin: 'A', destination: 'B', distance: 1 }
      result = double
      schema = double

      expect(result).to receive(:success?).and_return(true)

      expect(schema).to receive(:call).with(data).and_return(result)

      allow(DistributionPoints::Schemas::ToSave).to receive(:new).and_return(schema)

      described_class.new(origin: 'A', destination: 'B', distance: 1).valid?
    end
  end

  context '.by_origin_and_destination' do
    context 'with valid conditions' do
      it do
        record = create('A', 'B', 10)

        conditions = { origin: 'A', destination: 'B' }

        expect(described_class.by_origin_and_destination(conditions))
          .to include record
      end
    end

    context 'with invalid conditions' do
      it do
        invalid_conditions = [nil, 1, '', {}, []]

        only_errors =
          invalid_conditions.all? do |conditions|
            described_class.by_origin_and_destination(conditions)
          rescue Dry::Types::ConstraintError
            true
          end

        expect(only_errors).to be_truthy
      end
    end
  end
end
