# frozen_string_literal: true

require "rails_helper"

RSpec.describe NewsPost, type: :model do
  it_behaves_like "a valid factory"
  
  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:news_posts).counter_cache }
    it { is_expected.to belong_to(:location).optional.inverse_of(:news_posts).counter_cache }
    it { is_expected.to have_rich_text(:rich_content) }
    it { is_expected.to have_one_attached(:image) }
    it { is_expected.to have_one_attached(:pdf) }
  end

  describe "validations" do
    subject { build(:news_post) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:post_type) }

    context "when post_type is plain_text" do
      subject { build(:news_post, post_type: :plain_text) }

      it "validates presence of content" do
        news_post = build(:news_post, post_type: :plain_text, content: nil)
        expect(news_post).not_to be_valid
        expect(news_post.errors[:content]).to include("can't be blank for text posts")
      end

      it "is valid with content" do
        news_post = build(:news_post, post_type: :plain_text, content: "Some content")
        expect(news_post).to be_valid
      end
    end

    context "when post_type is rich_text" do
      subject { build(:news_post, :rich_text) }

      it "validates presence of rich_content" do
        news_post = build(:news_post, post_type: :rich_text)
        expect(news_post).not_to be_valid
        expect(news_post.errors[:rich_content]).to include("can't be blank for rich text posts")
      end

      it "is valid with rich_content" do
        news_post = build(:news_post, post_type: :rich_text)
        news_post.rich_content = ActionText::RichText.new(body: "Some rich content")
        expect(news_post).to be_valid
      end
    end

    context "when post_type is image_only" do
      subject { build(:news_post, :image_only) }

      it "validates presence of image" do
        news_post = build(:news_post, post_type: :image_only)
        expect(news_post).not_to be_valid
        expect(news_post.errors[:image]).to include("must be attached for image-only posts")
      end

      it "validates image file size limit" do
        news_post = build(:news_post, post_type: :image_only)
        # Create a large mock file
        large_file = double(
          "file",
          size: 11.megabytes,
          content_type: "image/png",
          original_filename: "large.png",
          tempfile: Tempfile.new,
          read: "x" * 11.megabytes
        )
        news_post.image.attach(
          io: StringIO.new("x" * 11.megabytes),
          filename: "large.png",
          content_type: "image/png"
        )
        expect(news_post).not_to be_valid
        expect(news_post.errors[:image]).to include(a_string_matching(/must be less than 10MB/))
      end

      it "validates image content type" do
        news_post = build(:news_post, post_type: :image_only)
        news_post.image.attach(
          io: StringIO.new("fake pdf content"),
          filename: "test.pdf",
          content_type: "application/pdf"
        )
        expect(news_post).not_to be_valid
        expect(news_post.errors[:image]).to include("must be a PNG, JPG, GIF, or WebP image")
      end

      it "accepts valid image with correct size and type" do
        news_post = build(:news_post, post_type: :image_only)
        news_post.image.attach(
          io: StringIO.new("x" * 1.megabyte),
          filename: "test.png",
          content_type: "image/png"
        )
        expect(news_post).to be_valid
      end
    end

    context "when post_type is pdf_only" do
      subject { build(:news_post, post_type: :pdf_only) }

      it "validates presence of pdf" do
        news_post = build(:news_post, post_type: :pdf_only)
        expect(news_post).not_to be_valid
        expect(news_post.errors[:pdf]).to include("must be attached for PDF posts")
      end

      it "validates pdf file size limit" do
        news_post = build(:news_post, post_type: :pdf_only)
        news_post.pdf.attach(
          io: StringIO.new("x" * 21.megabytes),
          filename: "large.pdf",
          content_type: "application/pdf"
        )
        expect(news_post).not_to be_valid
        expect(news_post.errors[:pdf]).to include(a_string_matching(/must be less than 20MB/))
      end

      it "validates pdf content type" do
        news_post = build(:news_post, post_type: :pdf_only)
        news_post.pdf.attach(
          io: StringIO.new("fake image content"),
          filename: "test.jpg",
          content_type: "image/jpeg"
        )
        expect(news_post).not_to be_valid
        expect(news_post.errors[:pdf]).to include("must be a PDF file")
      end

      it "accepts valid pdf with correct size and type" do
        news_post = build(:news_post, post_type: :pdf_only)
        news_post.pdf.attach(
          io: StringIO.new("x" * 5.megabytes),
          filename: "test.pdf",
          content_type: "application/pdf"
        )
        expect(news_post).to be_valid
      end
    end
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:post_type)
        .backed_by_column_of_type(:string)
        .with_values(plain_text: "plain_text", rich_text: "rich_text", image_only: "image_only", pdf_only: "pdf_only")
    }
  end

  describe "scopes" do
    let!(:published_post) { create(:news_post, :published) }
    let!(:unpublished_post) { create(:news_post, published: false) }
    let!(:archived_post) { create(:news_post, :archived) }
    let!(:location) { create(:location) }
    let!(:general_post) { create(:news_post, :general, :published) }
    let!(:location_post) { create(:news_post, location: location, published: true) }

    describe ".published" do
      it "returns only published posts" do
        result = NewsPost.published.to_a
        expect(result).to include(published_post, general_post, location_post)
        expect(result).not_to include(unpublished_post, archived_post)
      end
    end

    describe ".unpublished" do
      it "returns only unpublished posts" do
        expect(NewsPost.unpublished).to include(unpublished_post)
        expect(NewsPost.unpublished).not_to include(published_post, archived_post)
      end
    end

    describe ".archived" do
      it "returns only archived posts" do
        expect(NewsPost.archived).to include(archived_post)
        expect(NewsPost.archived).not_to include(published_post, unpublished_post)
      end
    end

    describe ".active" do
      it "returns only non-archived posts" do
        result = NewsPost.active.to_a
        expect(result).to include(published_post, unpublished_post, general_post, location_post)
        expect(result).not_to include(archived_post)
      end
    end

    describe ".general" do
      it "returns only posts without location" do
        expect(NewsPost.general).to include(general_post)
        expect(NewsPost.general).not_to include(location_post)
      end
    end

    describe ".for_location" do
      it "returns posts for specific location" do
        expect(NewsPost.for_location(location.id)).to include(location_post)
        expect(NewsPost.for_location(location.id)).not_to include(general_post)
      end
    end

    describe ".recent" do
      it "orders posts by created_at desc" do
        old_post = create(:news_post, created_at: 2.days.ago)
        new_post = create(:news_post, created_at: 1.hour.ago)

        posts = NewsPost.where(id: [old_post.id, new_post.id]).recent
        expect(posts.first).to eq(new_post)
        expect(posts.last).to eq(old_post)
      end
    end

    describe ".by_published_date" do
      it "orders posts by published_at desc, then created_at desc" do
        older_published = create(:news_post, published: true, published_at: 2.days.ago)
        newer_published = create(:news_post, published: true, published_at: 1.day.ago)

        posts = NewsPost.where(id: [older_published.id, newer_published.id]).by_published_date
        expect(posts.first).to eq(newer_published)
      end
    end

    describe ".for_display" do
      it "returns published, non-archived posts with associations" do
        result = NewsPost.for_display.to_a

        expect(result).to include(published_post, general_post, location_post)
        expect(result).not_to include(unpublished_post, archived_post)
      end
    end
  end

  describe "#general?" do
    it "returns true when location_id is nil" do
      post = build(:news_post, :general)
      expect(post.general?).to be true
    end

    it "returns false when location_id is present" do
      post = build(:news_post, location: create(:location))
      expect(post.general?).to be false
    end
  end

  describe "#location_specific?" do
    it "returns false when location_id is nil" do
      post = build(:news_post, :general)
      expect(post.location_specific?).to be false
    end

    it "returns true when location_id is present" do
      post = build(:news_post, location: create(:location))
      expect(post.location_specific?).to be true
    end
  end

  describe "#publish!" do
    let(:post) { create(:news_post, published: false) }

    it "sets published to true" do
      expect { post.publish! }.to change(post, :published).from(false).to(true)
    end

    it "sets published_at to current time" do
      freeze_time do
        post.publish!
        expect(post.published_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe "#unpublish!" do
    let(:post) { create(:news_post, :published) }

    it "sets published to false" do
      expect { post.unpublish! }.to change(post, :published).from(true).to(false)
    end
  end

  describe "#archive!" do
    let(:post) { create(:news_post, :published) }

    it "sets archived to true" do
      expect { post.archive! }.to change(post, :archived).from(false).to(true)
    end

    it "sets published to false" do
      expect { post.archive! }.to change(post, :published).from(true).to(false)
    end
  end

  describe "#restore!" do
    let(:post) { create(:news_post, :archived) }

    it "sets archived to false" do
      expect { post.restore! }.to change(post, :archived).from(true).to(false)
    end
  end

  describe "#status_badge" do
    it "returns 'Archived' for archived posts" do
      post = build(:news_post, :archived)
      expect(post.status_badge).to eq("Archived")
    end

    it "returns 'Published' for published posts" do
      post = build(:news_post, :published)
      expect(post.status_badge).to eq("Published")
    end

    it "returns 'Draft' for unpublished, non-archived posts" do
      post = build(:news_post, published: false, archived: false)
      expect(post.status_badge).to eq("Draft")
    end
  end

  describe "#scope_badge" do
    it "returns 'General' for general posts" do
      post = build(:news_post, :general)
      expect(post.scope_badge).to eq("General")
    end

    it "returns location code for location-specific posts" do
      location = create(:location, code: "NYC")
      post = build(:news_post, location: location)
      expect(post.scope_badge).to eq("Location: NYC")
    end
  end
end