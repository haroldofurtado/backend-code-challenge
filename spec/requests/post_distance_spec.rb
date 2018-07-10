require 'rails_helper'

RSpec.describe 'POST /distance', type: :request do
  def response_status_for(params)
    allow(DistributionPoints::RepositoryCommands::CreateOrUpdate)
      .to receive(:new).and_return spy

    post distribution_points_distance_path, params: params

    response.status
  end

  context 'with invalid body data' do
    it { expect(response_status_for('')).to eq 400 }
    it { expect(response_status_for('A')).to eq 400 }
    it { expect(response_status_for('A B')).to eq 400 }
    it { expect(response_status_for('A B C')).to eq 400 }
    it { expect(response_status_for('A B 1.')).to eq 400 }
  end

  context 'with valid body data' do
    it { expect(response_status_for('A B 1')).to eq 204 }
    it { expect(response_status_for(" C      D      2 \n\r")).to eq 204 }
    it { expect(response_status_for(" E \n\r F \n\r 3 \n\r")).to eq 204 }

    context 'after save' do
      it 'deletes routes cache' do
        Rails.cache.clear
        DistributionPoint.delete_all
        DistributionPoint.create(origin: 'AA', destination: 'BB', distance: 10)

        routes_cache =
          DistributionPoints::RoutesCache.new(Rails.cache).tap(&:read)

        fail unless routes_cache.exist?

        post distribution_points_distance_path, params: 'ZZ AA 100.10'

        fail unless response.status == 204

        expect(routes_cache.exist?).to be_falsey
      end
    end
  end
end
