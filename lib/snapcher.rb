# frozen_string_literal: true

require "active_record"
require_relative "snapcher/version"

module Snapcher
  class Error < StandardError; end
  # Your code goes here...

  class << self
    attr_accessor :column_name
    attr_writer :scanning_class

    def scanning_class
      # The scanning_class is set as String in the initializer. It can not be constantized during initialization and must
      # be constantized at runtime.
      @scanning_class = @scanning_class.safe_constantize if @scanning_class.is_a?(String)
      @scanning_class ||= Snapcher::Scanning
    end
  end
end

require "snapcher/junker"

ActiveSupport.on_load :active_record do
  require "snapcher/scanning"
  include Snapcher::Junker
end

require "snapcher/railtie"
