require 'rails_helper'

RSpec.describe 'GET /cost', type: :request do
  def response_for(orig, dest, weight)
    params = { origin: orig, destination: dest, weight: weight }

    get distribution_points_cost_calculation_path, params: params

    response
  end

  context 'with invalid params' do
    before { Rails.cache.clear }

    it { expect(response_for('', '', '').body).to be_blank }
    it { expect(response_for('', '', '').status).to eq 400 }
    it { expect(response_for('A', '', '').status).to eq 400 }
    it { expect(response_for('A', '', '').status).to eq 400 }
    it { expect(response_for('', 'B', '').status).to eq 400 }
    it { expect(response_for('', '', '1').status).to eq 400 }
    it { expect(response_for('A', 'B', '0').status).to eq 400 }
    it { expect(response_for('A', 'B', '51').status).to eq 400 }
  end

  context 'with valid params' do
    before do
      Rails.cache.clear
      DistributionPoint.delete_all

      [
        {origin: 'A', destination: 'B', distance: 10},
        {origin: 'B', destination: 'C', distance: 15},
        {origin: 'A', destination: 'C', distance: 30}
      ].each &DistributionPoint.method(:create!)
    end

    context 'and a distance wasn\'t found' do
      it { expect(response_for('A', 'D', '5').status).to eq 404 }
      it { expect(response_for('A', 'D', '5').body).to be_blank }
    end

    context 'and a distance was found' do
      it { expect(response_for('A', 'C', '5').status).to eq 200 }
      it { expect(response_for('A', 'C', '5').body).to eq '18.75' }
      it 'reads from routes cache' do
        routes_cache = spy

        allow(DistributionPoints::RoutesCache)
          .to receive(:new).and_return(routes_cache)

        response_for('A', 'C', '5')

        expect(routes_cache).to have_received(:read)
      end
    end
  end
end
