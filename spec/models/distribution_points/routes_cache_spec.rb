require 'rails_helper'

RSpec.describe DistributionPoints::RoutesCache, type: :model do
  before { Rails.cache.clear }

  subject { described_class.new(Rails.cache) }

  def create_distribution_point
    DistributionPoint.delete_all
    DistributionPoint.create origin: 'Z', destination: 'A', distance: 100
  end

  describe '#read' do
    context 'when wasn\'t cached data' do
      it { expect(subject.read).to be_nil }

      it 'avoids to cache nil' do
        subject.read

        expect(subject.exist?).to be_falsey
      end
    end

    context 'when was cached data' do
      it do
        create_distribution_point

        expect(subject.read).to match_array [
          ['Z', 'A', BigDecimal(100)]
        ]
      end

      it 'avoids querying in the database' do
        allow(DistributionPoint)
          .to receive(:pluck).once
                             .with(:origin, :destination, :distance)
                             .and_return([['A', 'B', BigDecimal(10)]])

        3.times { subject.read }
      end
    end
  end

  describe '#delete' do
    it do
      create_distribution_point

      subject.delete

      expect(subject.exist?).to be_falsey
    end
  end

  describe '#exist?' do
    context 'when wasn\'t cached data' do
      it { expect(subject.exist?).to be_falsey }
    end

    context 'when was cached data' do
      it do
        create_distribution_point

        subject.read

        expect(subject.exist?).to be_truthy
      end
    end
  end
end
