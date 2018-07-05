require 'rails_helper'

RSpec.describe DistributionPoints::DeserializeAndSave, type: :transaction do
  def result_to(input)
    described_class.new.call input
  end

  context 'when receive invalid serialized data' do
    it { expect(result_to(nil)).to be_a_failure }
    it { expect(result_to('')).to be_a_failure }
    it { expect(result_to('A 1')).to be_a_failure }
    it { expect(result_to('A B')).to be_a_failure }
    it { expect(result_to('AB 1')).to be_a_failure }
    it { expect(result_to('A B C')).to be_a_failure }
    it { expect(result_to('A B 1.')).to be_a_failure }
  end

  context 'when receive valid serialized data' do
    it do
      repository = double

      parsed_data = { origin: 'A', destination: 'B', distance: '1'}

      allow(repository)
        .to receive(:create_or_update!).with(parsed_data).and_return(spy)

      allow(DistributionPoints::Repository)
        .to receive(:new).and_return repository

      expect(result_to(" A B 1 \n\r")).to be_a_success
    end
  end
end
