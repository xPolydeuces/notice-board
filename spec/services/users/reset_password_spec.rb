require "rails_helper"

RSpec.describe Users::ResetPassword, type: :service do
  let(:current_user) { create(:user, :admin) }
  let(:target_user) { create(:user, :general) }
  let(:service) { described_class.new(user: target_user, current_user: current_user) }

  describe "#call" do
    context "when trying to reset own password" do
      let(:service) { described_class.new(user: current_user, current_user: current_user) }

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:cannot_reset_own)
      end

      it "does not change the password" do
        old_password = current_user.encrypted_password
        service.call
        current_user.reload
        expect(current_user.encrypted_password).to eq(old_password)
      end
    end

    context "when resetting another user's password successfully" do
      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end

      it "generates a temporary password" do
        expect(target_user).to receive(:generate_temporary_password).and_call_original
        service.call
      end

      it "saves the user" do
        service.call
        target_user.reload
        expect(target_user.force_password_change).to be true
      end

      it "changes the encrypted password" do
        old_password = target_user.encrypted_password
        service.call
        target_user.reload
        expect(target_user.encrypted_password).not_to eq(old_password)
      end

      it "sets force_password_change flag" do
        service.call
        target_user.reload
        expect(target_user.force_password_change).to be true
      end

      it "stores temporary password" do
        service.call
        expect(service.temporary_password).to be_present
        expect(service.temporary_password).to be_a(String)
        expect(service.temporary_password.length).to eq(12)
      end

      it "generates alphanumeric password" do
        service.call
        expect(service.temporary_password).to match(/\A[a-zA-Z0-9]+\z/)
      end
    end

    context "when save fails" do
      before do
        allow(target_user).to receive(:save).and_return(false)
      end

      it "returns failure" do
        result = service.call
        expect(result.success?).to be false
      end

      it "adds error message" do
        service.call
        expect(service.errors).to include(:save_failed)
      end

      it "does not expose temporary password" do
        service.call
        expect(service.temporary_password).to be_nil
      end
    end

    context "when admin resets general user password" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :general) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end
    end

    context "when superadmin resets admin password" do
      let(:current_user) { create(:user, :superadmin) }
      let(:target_user) { create(:user, :admin) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
      end
    end

    context "when admin resets location user password" do
      let(:current_user) { create(:user, :admin) }
      let(:target_user) { create(:user, :location) }

      it "returns success" do
        result = service.call
        expect(result.success?).to be true
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

  describe "#temporary_password" do
    context "before calling service" do
      it "returns nil" do
        expect(service.temporary_password).to be_nil
      end
    end

    context "after successful call" do
      it "returns the temporary password" do
        service.call
        expect(service.temporary_password).to be_present
      end
    end

    context "after failed call" do
      let(:service) { described_class.new(user: current_user, current_user: current_user) }

      it "returns nil" do
        service.call
        expect(service.temporary_password).to be_nil
      end
    end
  end
end
