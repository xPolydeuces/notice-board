require "rails_helper"

RSpec.describe Role, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "scopes" do
    describe "admin" do
      it { expect(described_class.admin).to eq(described_class.find_by(name: "Admin")) }
    end

    describe "teacher" do
      it { expect(described_class.teacher).to eq(described_class.find_by(name: "Teacher")) }
    end
  end
end
