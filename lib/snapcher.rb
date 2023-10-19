# frozen_string_literal: true

require "active_record"
require_relative "snapcher/version"

module Snapcher
  class Error < StandardError; end
  # Your code goes here...

  attr_writer :audit_class

  class << self
    attr_accessor :monitoring_column_name
  end
end

require "snapcher/auditor"

ActiveSupport.on_load :active_record do
  require "snapcher/snapshot"
  include Snapcher::Auditor
end

require "snapcher/railtie"
