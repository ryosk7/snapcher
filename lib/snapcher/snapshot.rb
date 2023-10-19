# frozen_string_literal: true

module Snapcher
  class Snapshot < ::ActiveRecord::Base
    belongs_to :snapshotable, polymorphic: true

    cattr_accessor :snapcher_class_names

    scope :snapshotable_finder, ->(snapshotable_id, snapshotable_type) { where(snapshotable_id: snapshotable_id, snapshotable_type: snapshotable_type) }
  end
end
