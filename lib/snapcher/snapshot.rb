# frozen_string_literal: true

require "set"

module Snapcher
  class Snapshot < ::ActiveRecord::Base
    belongs_to :snapchable, polymorphic: true

    cattr_accessor :snapcher_class_names

    # self.snapcher_class_names = Set.new

    scope :snapchable_finder, ->(snapchable_id, snapchable_type) { where(snapchable_id: snapchable_id, snapchable_type: snapchable_type) }
  end
end
