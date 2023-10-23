# frozen_string_literal: true

module Snapcher
  class Railtie < Rails::Railtie
    initializer "snapcher.sweeper" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.around_action Snapcher::Sweeper.new if defined?(ActionController::Base)
        ActionController::API.around_action Snapcher::Sweeper.new if defined?(ActionController::API)
      end
    end
  end
end
