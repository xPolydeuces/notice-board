RSpec.shared_examples "a model with presence validation" do |attribute|
  it "validates presence of #{attribute}" do
    expect(subject).to validate_presence_of(attribute)
  end
end
