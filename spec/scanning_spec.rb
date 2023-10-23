# frozen_string_literal: true

require 'debug'
require "spec_helper"

RSpec.describe "Scanning" do
  let(:user) { Models::ActiveRecord::User.create name: "Gillian Seed", role: Models::ActiveRecord::User.roles[:normal] }

  context "when the column whose data has been changed is role" do
    it "scanning data will be created during create action" do
      user # call then created.
      expect(user.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(user.scannings.last.column_name).to eq("role")
      expect(user.scannings.last.action).to eq("create")
      expect(user.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:normal].to_s)
    end

    it "scanning data will be created during update action" do
      user # call then created.
      user.admin!
      expect(user.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(user.scannings.last.column_name).to eq("role")
      expect(user.scannings.last.action).to eq("update")
      expect(user.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:admin].to_s)
    end

    it "scanning data will be created during destroy action" do
      user # call then created.
      user.destroy
      expect(user.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(user.scannings.last.column_name).to eq("role")
      expect(user.scannings.last.action).to eq("destroy")
      expect(user.scannings.last.after_params).to eq(nil)
    end
  end

  context "when the column whose data has been changed is role" do
    let!(:user) {
      Models::ActiveRecord::User.create name: "Gillian Seed", role: Models::ActiveRecord::User.roles[:normal]
    }

    it "scanning data is not created during update action" do
      user # call then created.
      user.update(name: "Mika Slayton")
      expect(user.scannings.count).to eq(1)
      expect(user.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(user.scannings.last.column_name).to eq("role")
      expect(user.scannings.last.action).to eq("create")
      expect(user.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:normal].to_s)
    end
  end
end
