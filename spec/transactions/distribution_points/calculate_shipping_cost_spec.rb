require 'rails_helper'

RSpec.describe DistributionPoints::CalculateShippingCost, type: :transaction do
  def result_to(input)
    params = ActionController::Parameters.new(input).permit!
    routes_fetcher = -> { [['A', 'B', 10], ['B', 'C', 15], ['A', 'C', 30]] }

    subject.with_step_args(fetch_routes: [routes_fetcher: routes_fetcher])
           .call(params)
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
        expect(result_to origin: 'A', destination: 'D', weight: 50)
          .to be_a_failure
      end
    end

    context 'and a distance was found' do
      it do
        expect(result_to origin: 'A', destination: 'C', weight: 5)
          .to be_a_success
      end

      it do
        result_to(origin: 'A', destination: 'C', weight: 5).bind do |value|
          expect(value).to eq 18.75
        end
      end
    end
  end
end
