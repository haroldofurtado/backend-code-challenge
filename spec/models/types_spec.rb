require 'rails_helper'

RSpec.describe Types, type: :model do
  it do
    expect(described_class)
      .to be_a_kind_of Dry::Types::BuilderMethods
  end
end
