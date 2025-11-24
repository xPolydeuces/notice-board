# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  it_behaves_like "a valid factory"
  it_behaves_like "a model with presence validation", :code
  it_behaves_like "a model with presence validation", :name

  describe "validations" do
    describe "code uniqueness" do
      subject { create(:location) }

      it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:news_posts).dependent(:nullify) }
  end

  describe "scopes" do
    describe ".active" do
      let!(:active_location) { create(:location, active: true) }
      let!(:inactive_location) { create(:location, :inactive) }

      it "returns only active locations" do
        expect(described_class.active).to include(active_location)
        expect(described_class.active).not_to include(inactive_location)
      end
    end

    describe ".ordered" do
      let!(:location_b) { create(:location, code: "B-001") }
      let!(:location_a) { create(:location, code: "A-001") }
      let!(:location_c) { create(:location, code: "C-001") }

      it "returns locations ordered by code" do
        expect(described_class.ordered).to eq([location_a, location_b, location_c])
      end
    end

    describe ".with_active_posts" do
      let!(:location_with_active) { create(:location, code: "LOC-1") }
      let!(:location_with_archived) { create(:location, code: "LOC-2") }
      let!(:location_with_draft) { create(:location, code: "LOC-3") }
      let!(:location_without_posts) { create(:location, code: "LOC-4") }

      before do
        create(:news_post, location: location_with_active, published: true, archived: false)
        create(:news_post, location: location_with_archived, published: true, archived: true)
        create(:news_post, location: location_with_draft, published: false, archived: false)
      end

      it "returns only locations with published and non-archived posts" do
        result = described_class.with_active_posts
        expect(result).to include(location_with_active)
        expect(result).not_to include(location_with_archived)
        expect(result).not_to include(location_with_draft)
        expect(result).not_to include(location_without_posts)
      end

      it "returns distinct locations" do
        # Create multiple active posts for same location
        create(:news_post, location: location_with_active, published: true, archived: false)
        create(:news_post, location: location_with_active, published: true, archived: false)

        result = described_class.with_active_posts
        expect(result.count).to eq(1)
        expect(result.first).to eq(location_with_active)
      end

      it "is chainable with other scopes" do
        inactive_location = create(:location, code: "INACTIVE", active: false)
        create(:news_post, location: inactive_location, published: true, archived: false)

        result = described_class.active.with_active_posts.ordered
        expect(result).to include(location_with_active)
        expect(result).not_to include(inactive_location)
      end
    end
  end

  describe "#full_name" do
    let(:location) { create(:location, code: "R-1", name: "Woronicza") }

    it "returns code and name formatted together" do
      expect(location.full_name).to eq("R-1 - Woronicza")
    end
  end

  describe "#has_active_posts?" do
    let(:location) { create(:location) }

    context "when location has no news posts" do
      it "returns false" do
        expect(location.has_active_posts?).to be false
      end
    end

    context "when location has only archived posts" do
      before do
        create(:news_post, location: location, published: true, archived: true)
      end

      it "returns false" do
        expect(location.has_active_posts?).to be false
      end
    end

    context "when location has only unpublished posts" do
      before do
        create(:news_post, location: location, published: false, archived: false)
      end

      it "returns false" do
        expect(location.has_active_posts?).to be false
      end
    end

    context "when location has published and non-archived posts" do
      before do
        create(:news_post, location: location, published: true, archived: false)
      end

      it "returns true" do
        expect(location.has_active_posts?).to be true
      end
    end

    context "when location has mixed posts" do
      before do
        create(:news_post, location: location, published: true, archived: false)
        create(:news_post, location: location, published: false, archived: false)
        create(:news_post, location: location, published: true, archived: true)
      end

      it "returns true when at least one post is published and not archived" do
        expect(location.has_active_posts?).to be true
      end
    end
  end

  describe "counter caches" do
    let(:location) { create(:location) }

    describe "users_count" do
      it "starts at 0" do
        expect(location.users_count).to eq(0)
      end

      it "increments when users are added" do
        create(:user, location: location)
        expect(location.reload.users_count).to eq(1)
      end
    end

    describe "news_posts_count" do
      it "starts at 0" do
        expect(location.news_posts_count).to eq(0)
      end

      it "increments when news posts are added" do
        create(:news_post, location: location)
        expect(location.reload.news_posts_count).to eq(1)
      end
    end
  end
end
