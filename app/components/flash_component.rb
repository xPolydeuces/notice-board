# Component for displaying flash messages with icons and colors
class FlashComponent < ApplicationViewComponent
  # Accept any object that responds to flash methods, not just Hash
  option :flash, default: proc { |*| {} }
  option :dismissible, Types::Bool, default: proc { |*| true }

  FLASH_TYPES = {
    notice: { icon: "check-circle", bg: "bg-green-100", text: "text-green-800", border: "border-green-300" },
    success: { icon: "check-circle", bg: "bg-green-100", text: "text-green-800", border: "border-green-300" },
    alert: { icon: "alert-circle", bg: "bg-red-100", text: "text-red-800", border: "border-red-300" },
    error: { icon: "alert-circle", bg: "bg-red-100", text: "text-red-800", border: "border-red-300" },
    warning: { icon: "alert-triangle", bg: "bg-yellow-100", text: "text-yellow-800", border: "border-yellow-300" },
    info: { icon: "info", bg: "bg-blue-100", text: "text-blue-800", border: "border-blue-300" }
  }.freeze

  def flash_messages
    # Convert FlashHash to regular hash for iteration
    # Transform keys to strings for consistency
    flash.to_hash.select { |type, _| FLASH_TYPES.key?(type.to_sym) }.transform_keys(&:to_s)
  end

  def flash_config(type)
    FLASH_TYPES[type.to_sym] || FLASH_TYPES[:info]
  end

  def render?
    flash_messages.any?
  end
end
