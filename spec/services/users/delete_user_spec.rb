# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::DeleteUser, type: :service do
  let(:current_user) { create(:user, :superadmin) }
  let(:target_user) { create(:user, :general) }
  let(:service) { described_class.new(user: target_user, current_user: current_user) }

  describe "#call" do
    context "when trying to delete self" do
      let(:service) { described_class.new(user: current_user, current_user: current_user) }

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:cannot_delete_self)
      end

      it "does not delete the user" do
        current_user # Force creation before count
        expect { service.call }.not_to change(User, :count)
      end
    end

    context "when trying to delete admin as non-superadmin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :admin) }

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:cannot_delete_admin)
      end

      it "does not delete the user" do
        current_user # Force creation
        target_user  # Force creation
        expect { service.call }.not_to change(User, :count)
      end
    end

    context "when trying to delete superadmin as non-superadmin" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :superadmin) }

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:cannot_delete_admin)
      end
    end

    context "when trying to delete the last superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { current_user }

      before do
        # Ensure only one superadmin exists
        User.where(role: :superadmin).where.not(id: current_user.id).destroy_all
      end

      it "returns failure" do
        service = described_class.new(user: current_user, current_user: current_user)
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service = described_class.new(user: current_user, current_user: current_user)
        service.call
        expect(service.errors).to include(:cannot_delete_self)
      end
    end

    context "when trying to delete another superadmin as superadmin" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :superadmin) }

      it "returns success" do
        # Ensure both superadmins exist
        current_user
        target_user
        expect(User.where(role: :superadmin).count).to eq(2)

        result = service.call
        expect(result.success?).to be true
      end

      it "deletes the user" do
        current_user
        target_user
        expect(User.where(role: :superadmin).count).to eq(2)

        expect { service.call }.to change(User, :count).by(-1)
      end
    end

    context "when deletion is valid for general user" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :general) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end

      it "deletes the user" do
        current_user
        target_user
        expect { service.call }.to change(User, :count).by(-1)
      end

      it "has no errors" do
        service.call
        expect(service.errors).to be_empty
      end
    end

    context "when deletion is valid for location user" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :location) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end

      it "deletes the user" do
        current_user
        target_user
        expect { service.call }.to change(User, :count).by(-1)
      end
    end

    context "when admin deletes general user" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end

      it "deletes the user" do
        current_user
        target_user
        expect { service.call }.to change(User, :count).by(-1)
      end
    end

    context "when admin deletes location user" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :location) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end

      it "deletes the user" do
        current_user
        target_user
        expect { service.call }.to change(User, :count).by(-1)
      end
    end

    context "when destroy fails" do
      before do
        allow(target_user).to receive(:destroy).and_return(false)
      end

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:destroy_failed)
      end
    end
  end

  describe "#success?" do
    context "when operation succeeds" do
      it "returns true" do
        service.call
        expect(service.success?).to be true
      end
    end

    context "when operation fails" do
      let(:service) { described_class.new(user: current_user, current_user: current_user) }

      it "returns false" do
        service.call
        expect(service.success?).to be false
      end
    end
  end
end