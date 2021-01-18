require "rails_helper"

RSpec.describe Api::V1::FriendshipsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/api/v1/friendships").to route_to(format: :json, controller: "api/v1/friendships", action: "create")
    end
  end
end
