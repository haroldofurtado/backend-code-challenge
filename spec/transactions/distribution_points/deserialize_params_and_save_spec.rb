require 'rails_helper'

RSpec.describe DistributionPoints::DeserializeParamsAndSave, type: :transaction do
  def result_to(input)
    described_class.new.call input
  end

  context 'when receive invalid serialized data' do
    it do
      invalid_data = [nil, '', 'A 1', 'A B', 'AB 1', 'A B C', 'A B 1.']

      results = invalid_data.map &method(:result_to)

      expect(results).to all( be_a_failure )
    end
  end

  context 'when receive valid serialized data' do
    it do
      repository = double

      parsed_data = { origin: 'A', destination: 'B', distance: '100'}

      allow(repository)
        .to receive(:create_or_update!).with(parsed_data).and_return(spy)

      allow(DistributionPoints::Repository)
        .to receive(:new).and_return repository

      expect(result_to("   A \n\r B \n\r 100   \n\r")).to be_a_success
    end
  end
end
