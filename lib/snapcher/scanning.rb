# frozen_string_literal: true

module Snapcher
  class Scanning < ::ActiveRecord::Base
    belongs_to :scannable, polymorphic: true

    cattr_accessor :snapcher_class_names

    scope :scannable_finder, lambda { |scannable_id, scannable_type|
                               where(scannable_id:, scannable_type:)
                             }
  end
end
