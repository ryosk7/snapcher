# frozen_string_literal: true

require "active_record"

module Snapcher
  class Error < StandardError; end
  # Your code goes here...

  class RequestStore < ActiveSupport::CurrentAttributes
    attribute :snapcher_store
  end

  class << self
    attr_accessor :column_name, :current_user
    attr_accessor :change_user_column
    attr_writer :scanning_class

    def scanning_class
      # The scanning_class is set as String in the initializer.
      # It can not be constantized during initialization and must
      # be constantized at runtime.
      @scanning_class = @scanning_class.safe_constantize if @scanning_class.is_a?(String)
      @scanning_class ||= Snapcher::Scanning
    end

    def store
      RequestStore.snapcher_store ||= {}
    end
  end

  @current_user_method = :current_user
end

require "snapcher/junker"

ActiveSupport.on_load :active_record do
  require "snapcher/scanning"
  include Snapcher::Junker
end

require "snapcher/sweeper"
require_relative "snapcher/railtie" if defined?(Rails::Railtie)
# require "snapcher/railtie"
