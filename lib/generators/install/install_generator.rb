require "rails"

module Snapcher
  class InstallGenerator < ::Rails::Generators::Base
    def initialize
    end

    def test1
      puts "test1"
    end
  end
end