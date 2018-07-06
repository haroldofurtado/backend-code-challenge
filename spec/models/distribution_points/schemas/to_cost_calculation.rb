require 'rails_helper'

RSpec.describe DistributionPoints::Schemas::ToCostCalculation, type: :model do
  def result_to(orig, dest, weight)
    subject.call origin: orig, destination: dest, weight: weight
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

    context 'invalid weight' do
      def input_with(weight)
        result_to('A', 'B', weight)
      end

      it do
        invalid_weights = [{}, [], '', '1.', nil, " \n\r", 0, 51]

        results = invalid_weights.map &method(:input_with)

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

  context 'weight value coercion' do
    def weight(value)
      result_to('A', 'B', value)[:weight]
    end

    it do
      weights = [1, 1.1, 1.15].map &method(:weight)

      expect(weights).to all( be_eq 1 )
    end

    it do
      weights = %w[1 1.1 1.15].map &method(:weight)

      expect(weights).to all( be_eq 1 )
    end
  end

  it do
    expect(result_to('A', 'B', 50).output)
      .to include origin: 'A', destination: 'B', weight: 50
  end

  it do
    expect(result_to('C', 'D', '0.01')).to be_a_success
  end
end
