# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Scanning" do
  let(:gillian) { Models::ActiveRecord::User.create name: "Gillian Seed", role: Models::ActiveRecord::User.roles[:snatcher] }
  let(:navigator) { Models::ActiveRecord::User.create name: "Metal Gear Mk. II", role: Models::ActiveRecord::User.roles[:navigator] }

  context "when the column whose data has been changed is role" do
    it "scanning data will be created during create action" do
      gillian # call then created.
      expect(gillian.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(gillian.scannings.last.column_name).to eq("role")
      expect(gillian.scannings.last.action).to eq("create")
      expect(gillian.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:snatcher].to_s)
    end

    it "scanning data will be created during update action" do
      gillian # call then created.
      gillian.juncker!
      expect(gillian.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(gillian.scannings.last.column_name).to eq("role")
      expect(gillian.scannings.last.action).to eq("update")
      expect(gillian.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:juncker].to_s)
    end

    it "scanning data will be created during destroy action" do
      gillian # call then created.
      gillian.destroy
      expect(gillian.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(gillian.scannings.last.column_name).to eq("role")
      expect(gillian.scannings.last.action).to eq("destroy")
      expect(gillian.scannings.last.after_params).to eq(nil)
    end
  end

  context "when the column whose data has been changed is not role" do
    let!(:gillian) do
      Models::ActiveRecord::User.create name: "Gillian Seed", role: Models::ActiveRecord::User.roles[:juncker]
    end

    it "scanning data is not created during update action" do
      gillian # call then created.
      gillian.update(name: "Mika Slayton")
      expect(gillian.scannings.count).to eq(1)
      expect(gillian.scannings.last.scannable_type).to eq("Models::ActiveRecord::User")
      expect(gillian.scannings.last.column_name).to eq("role")
      expect(gillian.scannings.last.action).to eq("create")
      expect(gillian.scannings.last.after_params).to eq(Models::ActiveRecord::User.roles[:juncker].to_s)
    end
  end

  context "when snatch_user option is specified" do
    let(:gillian) { Models::ActiveRecord::User.create name: "Gillian Seed", role: Models::ActiveRecord::User.roles[:juncker] }
    let(:navigator) { Models::ActiveRecord::User.create name: "Metal Gear Mk. II", role: Models::ActiveRecord::User.roles[:navigator] }
    let(:benson) { Models::ActiveRecord::User.create name: "Benson Cunningum", role: Models::ActiveRecord::User.roles[:juncker] }
    let(:order) { Models::ActiveRecord::Order.create scan_user_id: gillian.id, navigate_user_id: navigator.id}

    it "swap user_id update action" do
      order # call then created.
      order.update(scan_user_id: benson.id)
      expect(order.scannings.last.user_id).to eq(navigator.id)
    end
  end
end
