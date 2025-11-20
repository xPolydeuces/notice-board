# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:policy) { described_class.new(target_user, user: current_user) }

  describe "#index?" do
    context "when user is superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.index?).to be true
      end
    end

    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.index?).to be true
      end
    end

    context "when user is general" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.index?).to be false
      end
    end

    context "when user is location" do
      let(:current_user) { create(:user, :location) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.index?).to be false
      end
    end
  end

  describe "#create?" do
    context "when user is superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { build(:user, :general) }

      it "allows access" do
        expect(policy.create?).to be true
      end
    end

    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { build(:user, :general) }

      it "allows access" do
        expect(policy.create?).to be true
      end
    end

    context "when user is general" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { build(:user, :general) }

      it "denies access" do
        expect(policy.create?).to be false
      end
    end
  end

  describe "#new?" do
    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { build(:user, :general) }

      it "allows access (alias of create?)" do
        expect(policy.new?).to be true
        expect(policy.new?).to eq(policy.create?)
      end
    end
  end

  describe "#update?" do
    context "when superadmin updates general user" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.update?).to be true
      end
    end

    context "when superadmin updates admin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :admin) }

      it "allows access" do
        expect(policy.update?).to be true
      end
    end

    context "when superadmin updates another superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :superadmin) }

      it "allows access" do
        expect(policy.update?).to be true
      end
    end

    context "when admin updates general user" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.update?).to be true
      end
    end

    context "when admin tries to update superadmin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :superadmin) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "when admin tries to update another admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :admin) }

      it "allows access" do
        expect(policy.update?).to be true
      end
    end

    context "when general user tries to update" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end
  end

  describe "#edit?" do
    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access (alias of update?)" do
        expect(policy.edit?).to be true
        expect(policy.edit?).to eq(policy.update?)
      end
    end
  end

  describe "#destroy?" do
    context "when superadmin deletes general user" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.destroy?).to be true
      end
    end

    context "when superadmin deletes admin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :admin) }

      it "allows access" do
        expect(policy.destroy?).to be true
      end
    end

    context "when superadmin deletes another superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :superadmin) }

      it "allows access" do
        expect(policy.destroy?).to be true
      end
    end

    context "when admin tries to delete superadmin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :superadmin) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "when admin deletes general user" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.destroy?).to be true
      end
    end

    context "when general user tries to delete" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end
  end

  describe "#reset_password?" do
    context "when superadmin resets general user password" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.reset_password?).to be true
      end
    end

    context "when admin resets general user password" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.reset_password?).to be true
      end
    end

    context "when user tries to reset own password" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { current_user }

      it "denies access" do
        expect(policy.reset_password?).to be false
      end
    end

    context "when general user tries to reset password" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.reset_password?).to be false
      end
    end
  end

  describe "#assign_superadmin_role?" do
    context "when user is superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :admin) }

      it "allows access" do
        expect(policy.assign_superadmin_role?).to be true
      end
    end

    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.assign_superadmin_role?).to be false
      end
    end

    context "when user is general" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.assign_superadmin_role?).to be false
      end
    end
  end

  describe "#manage_locations?" do
    context "when user is superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.manage_locations?).to be true
      end
    end

    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.manage_locations?).to be true
      end
    end

    context "when user is general" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.manage_locations?).to be false
      end
    end
  end

  describe "#manage_rss_feeds?" do
    context "when user is superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.manage_rss_feeds?).to be true
      end
    end

    context "when user is admin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "allows access" do
        expect(policy.manage_rss_feeds?).to be true
      end
    end

    context "when user is general" do
      let(:current_user) { create(:user, :general) }
      let(:target_user) { create(:user, :general) }

      it "denies access" do
        expect(policy.manage_rss_feeds?).to be false
      end
    end
  end
end