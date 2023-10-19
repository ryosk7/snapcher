# frozen_string_literal: true

module Snapcher
  class Snapshot < ::ActiveRecord::Base
    belongs_to :snapchable, polymorphic: true

    cattr_accessor :snapcher_class_names

    scope :snapchable_finder, ->(snapchable_id, snapchable_type) { where(snapchable_id: snapchable_id, snapchable_type: snapchable_type) }
  end
end
