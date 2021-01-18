require "rails_helper"

RSpec.describe Api::V1::MembersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v1/members").to route_to(format: :json, controller: "api/v1/members", action: "index")
    end

    it "routes to #show" do
      expect(get: "/api/v1/members/1").to route_to(format: :json, controller: "api/v1/members", action: "show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/api/v1/members").to route_to(format: :json, controller: "api/v1/members", action: "create")
    end

    it "routes to #update via PUT" do
      expect(put: "/api/v1/members/1").to route_to(format: :json, controller: "api/v1/members", action: "update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/v1/members/1").to route_to(format: :json, controller: "api/v1/members", action: "update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/api/v1/members/1").to route_to(format: :json, controller: "api/v1/members", action: "destroy", id: "1")
    end
  end
end
