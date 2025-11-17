# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it_behaves_like "a valid factory"
  describe "associations" do
    it { is_expected.to belong_to(:location).optional.inverse_of(:users).counter_cache }
    it { is_expected.to have_many(:news_posts).dependent(:nullify).inverse_of(:user) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(20) }
    it { is_expected.to allow_value("user123").for(:username) }
    it { is_expected.to allow_value("test_user").for(:username) }
    it { is_expected.not_to allow_value("user@123").for(:username) }
    it { is_expected.not_to allow_value("user 123").for(:username) }
    it { is_expected.not_to allow_value("user-123").for(:username) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }

    context "when role is location" do
      subject { build(:user, :location) }

      it { is_expected.to validate_presence_of(:location) }
    end

    context "when role is not location" do
      subject { build(:user, :general) }

      it { is_expected.not_to validate_presence_of(:location) }
    end
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(general: 0, location: 1, admin: 2, superadmin: 3)
        .with_default(:general)
    }
  end

  describe "callbacks" do
    describe "before_validation :downcase_username" do
      it "downcases username before validation" do
        user = build(:user, username: "TestUser123")
        user.valid?
        expect(user.username).to eq("testuser123")
      end

      it "handles nil username gracefully" do
        user = build(:user, username: nil)
        expect { user.valid? }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    describe ".alphabetical" do
      it "orders users by username" do
        user_z = create(:user, username: "zebra")
        user_a = create(:user, username: "apple")
        user_m = create(:user, username: "middle")

        expect(User.alphabetical).to eq([user_a, user_m, user_z])
      end
    end

    describe ".by_role" do
      it "filters users by role" do
        admin = create(:user, :admin)
        general = create(:user, :general)

        expect(User.by_role(:admin)).to include(admin)
        expect(User.by_role(:admin)).not_to include(general)
      end
    end
  end

  describe "#can_edit_location?" do
    let(:location) { create(:location) }
    let(:other_location) { create(:location) }

    context "when user is superadmin" do
      let(:user) { create(:user, :superadmin) }

      it "returns true for any location" do
        expect(user.can_edit_location?(location)).to be true
        expect(user.can_edit_location?(other_location)).to be true
      end
    end

    context "when user is admin" do
      let(:user) { create(:user, :admin) }

      it "returns true for any location" do
        expect(user.can_edit_location?(location)).to be true
      end
    end

    context "when user is location user" do
      let(:user) { create(:user, role: :location, location: location) }

      it "returns true for their own location" do
        expect(user.can_edit_location?(location)).to be true
      end

      it "returns false for other locations" do
        expect(user.can_edit_location?(other_location)).to be false
      end
    end

    context "when user is general" do
      let(:user) { create(:user, :general) }

      it "returns false for any location" do
        expect(user.can_edit_location?(location)).to be false
      end
    end
  end

  describe "#can_create_general_news?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.can_create_general_news?).to be true
    end

    it "returns true for admin" do
      user = create(:user, :admin)
      expect(user.can_create_general_news?).to be true
    end

    it "returns true for general user" do
      user = create(:user, :general)
      expect(user.can_create_general_news?).to be true
    end

    it "returns false for location user" do
      user = create(:user, :location)
      expect(user.can_create_general_news?).to be false
    end
  end

  describe "#can_manage_users?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.can_manage_users?).to be true
    end

    it "returns true for admin" do
      user = create(:user, :admin)
      expect(user.can_manage_users?).to be true
    end

    it "returns false for general user" do
      user = create(:user, :general)
      expect(user.can_manage_users?).to be false
    end

    it "returns false for location user" do
      user = create(:user, :location)
      expect(user.can_manage_users?).to be false
    end
  end

  describe "#can_manage_locations?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.can_manage_locations?).to be true
    end

    it "returns true for admin" do
      user = create(:user, :admin)
      expect(user.can_manage_locations?).to be true
    end

    it "returns false for general user" do
      user = create(:user, :general)
      expect(user.can_manage_locations?).to be false
    end
  end

  describe "#can_manage_rss_feeds?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.can_manage_rss_feeds?).to be true
    end

    it "returns true for admin" do
      user = create(:user, :admin)
      expect(user.can_manage_rss_feeds?).to be true
    end

    it "returns false for general user" do
      user = create(:user, :general)
      expect(user.can_manage_rss_feeds?).to be false
    end
  end

  describe "#can_delete_admin?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.can_delete_admin?).to be true
    end

    it "returns false for admin" do
      user = create(:user, :admin)
      expect(user.can_delete_admin?).to be false
    end

    it "returns false for general user" do
      user = create(:user, :general)
      expect(user.can_delete_admin?).to be false
    end
  end

  describe "#admin_or_superadmin?" do
    it "returns true for superadmin" do
      user = create(:user, :superadmin)
      expect(user.admin_or_superadmin?).to be true
    end

    it "returns true for admin" do
      user = create(:user, :admin)
      expect(user.admin_or_superadmin?).to be true
    end

    it "returns false for general user" do
      user = create(:user, :general)
      expect(user.admin_or_superadmin?).to be false
    end

    it "returns false for location user" do
      user = create(:user, :location)
      expect(user.admin_or_superadmin?).to be false
    end
  end

  describe "#display_name" do
    it "returns the username" do
      user = create(:user, username: "testuser")
      expect(user.display_name).to eq("testuser")
    end
  end

  describe "#to_s" do
    it "returns the display name" do
      user = create(:user, username: "testuser")
      expect(user.to_s).to eq("testuser")
    end
  end

  describe "Devise overrides" do
    let(:user) { create(:user) }

    describe "#email_required?" do
      it "returns false" do
        expect(user.email_required?).to be false
      end
    end

    describe "#email_changed?" do
      it "returns false" do
        expect(user.email_changed?).to be false
      end
    end

    describe "#will_save_change_to_email?" do
      it "returns false" do
        expect(user.will_save_change_to_email?).to be false
      end
    end
  end

  describe "Password management" do
    let(:user) { create(:user, :general) }

    describe "#generate_temporary_password" do
      it "generates a 12 character password" do
        temp_password = user.generate_temporary_password
        expect(temp_password.length).to eq(12)
      end

      it "sets the password on the user" do
        temp_password = user.generate_temporary_password
        expect(user.password).to eq(temp_password)
        expect(user.password_confirmation).to eq(temp_password)
      end

      it "sets force_password_change flag" do
        user.generate_temporary_password
        expect(user.force_password_change).to be true
      end

      it "returns the temporary password" do
        temp_password = user.generate_temporary_password
        expect(temp_password).to be_present
        expect(temp_password).to be_a(String)
      end

      it "generates alphanumeric password" do
        temp_password = user.generate_temporary_password
        expect(temp_password).to match(/\A[a-zA-Z0-9]+\z/)
      end

      it "changes encrypted_password after save" do
        old_encrypted_password = user.encrypted_password
        user.generate_temporary_password
        user.save
        expect(user.encrypted_password).not_to eq(old_encrypted_password)
      end
    end

    describe "#force_password_change?" do
      context "when force_password_change is true" do
        let(:user) { create(:user, force_password_change: true) }

        it "returns true" do
          expect(user.force_password_change?).to be true
        end
      end

      context "when force_password_change is false" do
        let(:user) { create(:user, force_password_change: false) }

        it "returns false" do
          expect(user.force_password_change?).to be false
        end
      end
    end
  end
end