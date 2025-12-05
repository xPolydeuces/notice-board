require "rails_helper"

RSpec.describe NewsPostPolicy, type: :policy do
  let(:policy) { described_class.new(record, user: user) }

  describe "Scope" do
    let!(:general_post) { create(:news_post, :general) }
    let!(:location1) { create(:location, code: "LOC-1") }
    let!(:location2) { create(:location, code: "LOC-2") }
    let!(:location1_post) { create(:news_post, location: location1) }
    let!(:location2_post) { create(:news_post, location: location2) }

    context "when user is admin" do
      let(:user) { create(:user, :admin) }

      it "returns all posts" do
        policy = described_class.new(user: user)
        scope = policy.apply_scope(NewsPost.all, type: :active_record_relation)
        expect(scope.to_a).to include(general_post, location1_post, location2_post)
      end
    end

    context "when user is location user" do
      let(:user) { create(:user, :location, location: location1) }

      it "returns only posts from their location" do
        policy = described_class.new(user: user)
        scope = policy.apply_scope(NewsPost.all, type: :active_record_relation)
        expect(scope).to include(location1_post)
        expect(scope).not_to include(location2_post, general_post)
      end
    end

    context "when user is general user" do
      let(:user) { create(:user, :general) }

      it "returns all posts" do
        policy = described_class.new(user: user)
        scope = policy.apply_scope(NewsPost.all, type: :active_record_relation)
        expect(scope.to_a).to include(general_post, location1_post, location2_post)
      end
    end
  end

  describe "#manage?" do
    context "when user is admin" do
      let(:user) { create(:user, :admin) }
      let(:record) { create(:news_post, :general) }

      it "allows managing any post" do
        expect(policy).to be_allowed_to(:manage?)
      end
    end

    context "when location user manages post from their location" do
      let(:location) { create(:location) }
      let(:user) { create(:user, :location, location: location) }
      let(:record) { create(:news_post, location: location) }

      it "allows managing" do
        expect(policy).to be_allowed_to(:manage?)
      end
    end

    context "when location user manages post from different location" do
      let(:location) { create(:location) }
      let(:other_location) { create(:location, code: "OTHER") }
      let(:user) { create(:user, :location, location: location) }
      let(:record) { create(:news_post, location: other_location) }

      it "denies managing" do
        expect(policy).not_to be_allowed_to(:manage?)
      end
    end

    context "when location user manages general post" do
      let(:location) { create(:location) }
      let(:user) { create(:user, :location, location: location) }
      let(:record) { create(:news_post, :general) }

      it "denies managing" do
        expect(policy).not_to be_allowed_to(:manage?)
      end
    end

    context "when general user manages general post" do
      let(:user) { create(:user, :general) }
      let(:record) { create(:news_post, :general) }

      it "allows managing" do
        expect(policy).to be_allowed_to(:manage?)
      end
    end

    context "when general user manages location post" do
      let(:location) { create(:location) }
      let(:user) { create(:user, :general) }
      let(:record) { create(:news_post, location: location) }

      it "denies managing" do
        expect(policy).not_to be_allowed_to(:manage?)
      end
    end
  end

  describe "#edit?" do
    let(:location) { create(:location) }
    let(:user) { create(:user, :location, location: location) }
    let(:record) { create(:news_post, location: location) }

    it "delegates to manage?" do
      expect(policy).to be_allowed_to(:edit?)
    end
  end

  describe "#update?" do
    let(:location) { create(:location) }
    let(:user) { create(:user, :location, location: location) }
    let(:record) { create(:news_post, location: location) }

    it "delegates to manage?" do
      expect(policy).to be_allowed_to(:update?)
    end
  end

  describe "#destroy?" do
    let(:location) { create(:location) }
    let(:user) { create(:user, :location, location: location) }
    let(:record) { create(:news_post, location: location) }

    it "delegates to manage?" do
      expect(policy).to be_allowed_to(:destroy?)
    end
  end

  describe "#create?" do
    let(:user) { create(:user, :general) }
    let(:record) { NewsPost.new }

    it "allows all authenticated users to create" do
      expect(policy).to be_allowed_to(:create?)
    end
  end

  describe "#assign_location?" do
    context "when user is admin" do
      let(:user) { create(:user, :admin) }
      let(:record) { NewsPost.new }

      it "allows assigning location" do
        expect(policy).to be_allowed_to(:assign_location?)
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user, :general) }
      let(:record) { NewsPost.new }

      it "denies assigning location" do
        expect(policy).not_to be_allowed_to(:assign_location?)
      end
    end
  end
end
