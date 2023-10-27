# frozen_string_literal: true

module Snapcher
  class Scanning < ::ActiveRecord::Base
    belongs_to :scannable, polymorphic: true

    cattr_accessor :snapcher_class_names

    scope :scannable_finder, lambda { |scannable_id, scannable_type|
                               where(scannable_id:, scannable_type:)
                             }
  end

  def set_version_number
    if action == "create"
      self.version = 1
    else
      collection = (ActiveRecord::VERSION::MAJOR >= 6) ? self.class.unscoped : self.class
      max = collection.auditable_finder(scannable_id, scannable_type).maximum(:version) || 0
      self.version = max + 1
    end
  end
end
