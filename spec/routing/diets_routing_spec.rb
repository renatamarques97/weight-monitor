require "rails_helper"

RSpec.describe DietsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/diets").to route_to("diets#index")
    end

    it "routes to #new" do
      expect(get: "/diets/new").to route_to("diets#new")
    end

    it "routes to #show" do
      expect(get: "/diets/1").to route_to("diets#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/diets/1/edit").to route_to("diets#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/diets").to route_to("diets#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/diets/1").to route_to("diets#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/diets/1").to route_to("diets#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/diets/1").to route_to("diets#destroy", id: "1")
    end
  end
end
