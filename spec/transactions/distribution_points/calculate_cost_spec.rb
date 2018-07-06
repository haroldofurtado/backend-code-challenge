require 'rails_helper'

RSpec.describe DistributionPoints::CalculateCost, type: :transaction do
  def result_to(input)
    params = ActionController::Parameters.new(input).permit!

    described_class.new.call params
  end

  context 'when receive invalid params' do
    it do
      invalid_params = [
        {},
        {origin: ' ', destination: '', weight: 1},
        {origin: '', destination: 'B', weight: 1},
        {origin: 'A', destination: '', weight: 1},
        {origin: 'A', destination: 'B', weight: 0},
        {origin: 'A', destination: 'B', weight: 51},
      ]

      results = invalid_params.map &method(:result_to)

      expect(results).to all( be_a_failure )
    end
  end

  context 'when receive valid params' do
    context 'and a distance wasn\'t found' do
      it do
        expect(result_to origin: 'A', destination: 'B', weight: 50)
          .to be_a_failure
      end
    end

    context 'and a distance was found' do
      before { DistributionPoint.delete_all }

      def create_distribution_point
        DistributionPoint.create origin: 'A', destination: 'B', distance: 10
      end

      it do
        create_distribution_point

        expect(result_to origin: 'A', destination: 'B', weight: 50)
          .to be_a_success
      end

      it do
        create_distribution_point

        result_to(origin: 'A', destination: 'B', weight: 50).bind do |value|
          expect(value).to eq 75.0
        end
      end
    end
  end
end
