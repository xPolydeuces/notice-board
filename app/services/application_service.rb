# Base class for service objects that provides common result handling
class ApplicationService
  attr_reader :errors

  def initialize
    @errors = []
    @success = false
  end

  def success?
    @success == true
  end

  private

  def success
    @success = true
    self
  end

  def failure(reason, message = nil)
    @success = false
    @errors << reason
    @errors << message if message
    self
  end
end
