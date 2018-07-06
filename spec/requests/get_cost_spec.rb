require 'rails_helper'

RSpec.describe 'GET /cost', type: :request do
  def response_for(orig, dest, weight, distance = nil)
    if distance
      allow(DistributionPoint)
        .to receive(:pick_distance_by!).and_return distance
    end

    params = { origin: orig, destination: dest, weight: weight }

    get distribution_points_cost_calculation_path, params: params

    response
  end

  context 'with valid params' do
    let(:params) { ['A', 'C', '5', 25] }

    it { expect(response_for(*params).status).to eq 200 }
    it { expect(response_for(*params).body).to eq '18.75' }

    context 'and a distance was found' do
      let(:params) { ['A', 'C', '50'] }

      it { expect(response_for(*params).status).to eq 400 }
      it { expect(response_for(*params).body).to be_blank }
    end
  end

  context 'with invalid params' do
    it { expect(response_for('', '', '').body).to be_blank }
    it { expect(response_for('', '', '').status).to eq 400 }
    it { expect(response_for('A', '', '').status).to eq 400 }
    it { expect(response_for('A', '', '').status).to eq 400 }
    it { expect(response_for('', 'B', '').status).to eq 400 }
    it { expect(response_for('', '', '1').status).to eq 400 }
    it { expect(response_for('A', 'B', '0').status).to eq 400 }
    it { expect(response_for('A', 'B', '51').status).to eq 400 }
  end
end
