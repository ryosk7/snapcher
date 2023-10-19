# frozen_string_literal: true

require "active_record"
require_relative "snapcher/version"

module Snapcher
  class Error < StandardError; end
  # Your code goes here...

  attr_writer :audit_class

  class << self
    attr_accessor \
    :auditing_enabled,
    :current_user_method,
    :ignored_attributes,
    :max_audits,
    :store_synthesized_enums,
    :monitoring_column_name
  end

  @ignored_attributes = %w[lock_version created_at updated_at created_on updated_on]
  @store_synthesized_enums = false
end

require "snapcher/auditor"

ActiveSupport.on_load :active_record do
  require "snapcher/snapshot"
  include Snapcher::Auditor
end

require "snapcher/railtie"
