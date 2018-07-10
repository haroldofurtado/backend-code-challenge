require 'rails_helper'

RSpec.describe DistributionPoints::DeserializeParamsAndSave, type: :transaction do
  def result_to(input, routes_cache_step_arg: nil)
    described_class
      .new
      .with_step_args(handle_routes_cache: [routes_cache_step_arg || spy])
      .call input
  end

  context 'when receive invalid serialized data' do
    it do
      invalid_data = [nil, '', 'A 1', 'A B', 'AB 1', 'A B C', 'A B 1.']

      results = invalid_data.map &method(:result_to)

      expect(results).to all( be_a_failure )
    end
  end

  context 'when receive valid serialized data' do
    def mock_repository_with(parsed_params, repository_result = nil)
      repository = double

      allow(repository).to receive(:call).with(parsed_params)
                                         .and_return(repository_result || spy)

      allow(DistributionPoints::RepositoryCommands::CreateOrUpdate)
        .to receive(:new).and_return repository
    end

    it do
      parsed_params = { origin: 'A', destination: 'B', distance: '100' }

      mock_repository_with parsed_params

      expect(result_to("   A \n\r B \n\r 100   \n\r")).to be_a_success
    end

    context 'routes cache deleting' do
      let(:parsed_params) { { origin: 'A', destination: 'B', distance: '100' } }

      def repository_result(action, ouput)
        DistributionPoints::RepositoryCommands::CreateOrUpdate::Result
          .new(action, output)
      end

      context 'when create a distribution point' do
        it 'deletes cache' do
          mock_repository_with parsed_params, repository_result(:create, spy)

          routes_cache = spy

          result_to('A B 100', routes_cache_step_arg: routes_cache)

          expect(routes_cache).to have_received(:delete)
        end
      end

      context 'when update a distribution point' do
        context 'with the same distance value' do
          it 'keeps cache' do
            mock_repository_with parsed_params, repository_result(:update, 0)

            routes_cache = spy

            result_to('A B 100', routes_cache_step_arg: routes_cache)

            expect(routes_cache).to_not have_received(:delete)
          end
        end

        context 'with a different distance value' do
          it 'deletes cache' do
            mock_repository_with parsed_params, repository_result(:update, 1)

            routes_cache = spy

            result_to('A B 100', routes_cache_step_arg: routes_cache)

            expect(routes_cache).to_not have_received(:delete)
          end
        end
      end
    end
  end
end
