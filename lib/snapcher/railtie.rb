# frozen_string_literal: true

module Snapcher
  class Railtie < Rails::Railtie
    initializer "snapcher.sweeper" do
      ActiveSupport.on_load(:action_controller) do
        if defined?(ActionController::Base)
          ActionController::Base.around_action Snapcher::Sweeper.new
        end
        if defined?(ActionController::API)
          ActionController::API.around_action Snapcher::Sweeper.new
        end
      end
    end
  end
end
