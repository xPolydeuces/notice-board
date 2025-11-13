# frozen_string_literal: true

RSpec.shared_examples "a model with uniqueness validation" do |attribute|
  it "validates uniqueness of #{attribute}" do
    create(described_class.name.underscore.to_sym, attribute => "unique_value")
    duplicate = build(described_class.name.underscore.to_sym, attribute => "unique_value")
    expect(duplicate).not_to be_valid
  end
end