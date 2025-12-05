RSpec.shared_examples "a valid factory" do
  it "has a valid factory" do
    expect(build(described_class.name.underscore.to_sym)).to be_valid
  end

  it "can be created and persisted" do
    expect(create(described_class.name.underscore.to_sym)).to be_persisted
  end
end
