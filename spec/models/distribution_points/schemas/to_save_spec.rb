require 'rails_helper'

RSpec.describe DistributionPoints::Schemas::ToSave, type: :model do
  def result_to(orig, dest, dist)
    subject.call origin: orig, destination: dest, distance: dist
  end

  context 'with invalid data' do
    context 'invalid origin' do
      def input_with(origin)
        result_to(origin, 'B', 1)
      end

      it do
        invalid_origins = [1, {}, [], '', nil, " \n\r"]

        results = invalid_origins.map &method(:input_with)

        expect(results).to all( be_a_failure )
      end
    end

    context 'invalid destination' do
      def input_with(destination)
        result_to('A', destination, 2)
      end

      it do
        invalid_destinations = [1, {}, [], '', nil, " \n\r"]

        results = invalid_destinations.map &method(:input_with)

        expect(results).to all( be_a_failure )
      end
    end

    context 'invalid distance' do
      def input_with(distance)
        result_to('A', 'B', distance)
      end

      it do
        invalid_distances = [{}, [], '', '1.', nil, " \n\r", 0, 100_001]

        results = invalid_distances.map &method(:input_with)

        expect(results).to all( be_a_failure )
      end
    end

    context 'same origin and destination' do
      it { expect(result_to('A', ' A ', 1)).to be_a_failure }
    end
  end

  context 'input preprocessing' do
    it do
      expect(result_to(' A ', ' B ', 1).output)
        .to include origin: 'A', destination: 'B'
    end
  end

  context 'distance value coercion' do
    def distance(value)
      result_to('A', 'B', value)[:distance]
    end

    let(:decimal_values) { decimals = %w[1 1.1 1.15].map &method(:BigDecimal) }

    it do
      distances = [1, 1.1, 1.15].map &method(:distance)

      expect(distances).to match_array( decimal_values )
    end

    it do
      distances = %w[1 1.1 1.15].map &method(:distance)

      expect(distances).to match_array( decimal_values )
    end
  end

  it do
    expect(result_to('A', 'B', 100_000).output)
      .to include origin: 'A', destination: 'B', distance: BigDecimal('100000')
  end

  it do
    expect(result_to('C', 'D', '0.01')).to be_a_success
  end
end
