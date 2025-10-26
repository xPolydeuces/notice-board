# Shared examples for common Rails model testing patterns
RSpec.shared_examples "a valid factory" do |factory_name = nil|
  factory_name ||= described_class.name.underscore.to_sym

  it "has a valid factory" do
    expect(build(factory_name)).to be_valid
  end

  it "can be created" do
    expect { create(factory_name) }.not_to raise_error
  end
end

RSpec.shared_examples "a model with presence validation" do |attribute|
  it "validates presence of #{attribute}" do
    expect(subject).to validate_presence_of(attribute)
  end
end

RSpec.shared_examples "a model with uniqueness validation" do |attribute|
  it "validates uniqueness of #{attribute}" do
    expect(subject).to validate_uniqueness_of(attribute)
  end
end
