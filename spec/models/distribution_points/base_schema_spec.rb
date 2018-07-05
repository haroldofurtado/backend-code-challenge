require 'rails_helper'

RSpec.describe DistributionPoints::BaseSchema, type: :model do
  def result_to(origin, destination, distance)
    subject.call origin: origin, destination: destination, distance: distance
  end

  context 'with invalid data' do
    context 'invalid origin' do
      def input_with(origin:)
        result_to(origin, 'B', 1)
      end

      it { expect(input_with(origin: 1)).to be_a_failure }
      it { expect(input_with(origin: {})).to be_a_failure }
      it { expect(input_with(origin: [])).to be_a_failure }
      it { expect(input_with(origin: '')).to be_a_failure }
      it { expect(input_with(origin: nil)).to be_a_failure }
      it { expect(input_with(origin: " \n\r")).to be_a_failure }
    end

    context 'invalid destination' do
      def input_with(destination:)
        result_to('A', destination, 2)
      end

      it { expect(input_with(destination: 1)).to be_a_failure }
      it { expect(input_with(destination: {})).to be_a_failure }
      it { expect(input_with(destination: [])).to be_a_failure }
      it { expect(input_with(destination: '')).to be_a_failure }
      it { expect(input_with(destination: nil)).to be_a_failure }
      it { expect(input_with(destination: " \n\r")).to be_a_failure }
    end

    context 'invalid distance' do
      def input_with(distance:)
        result_to('A', 'B', distance)
      end

      it { expect(input_with(distance: {})).to be_a_failure }
      it { expect(input_with(distance: [])).to be_a_failure }
      it { expect(input_with(distance: '')).to be_a_failure }
      it { expect(input_with(distance: '1.')).to be_a_failure }
      it { expect(input_with(distance: nil)).to be_a_failure }
      it { expect(input_with(distance: " \n\r")).to be_a_failure }
      it { expect(input_with(distance: 0)).to be_a_failure }
      it { expect(input_with(distance: 100_001)).to be_a_failure }
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

    it { expect(distance(1)).to eq BigDecimal('1') }
    it { expect(distance(1.1)).to eq BigDecimal('1.1') }
    it { expect(distance(1.15)).to eq BigDecimal('1.15') }

    it { expect(distance('1')).to eq BigDecimal('1') }
    it { expect(distance('1.1')).to eq BigDecimal('1.1') }
    it { expect(distance('1.15')).to eq BigDecimal('1.15') }
  end

  it do
    expect(result_to('A', 'B', 100_000).output)
      .to include origin: 'A', destination: 'B', distance: BigDecimal('100000')
  end

  it do
    expect(result_to('C', 'D', '0.01')).to be_a_success
  end
end
