require 'rails_helper'

module Api::V1
  RSpec.describe TrackedDirectoriesController do

    describe "index" do
      describe "GET" do
        it "succeeds" do
          get :index
          expect(response).to be_success
        end
      end
      describe "HEAD" do
        it "succeeds" do
          head :index
          expect(response).to be_success
        end
      end
    end

    describe "show" do
      let(:dir) { TrackedDirectory.create!(path: fixture_path) }
      describe "GET" do
        it "succeeds" do
          get :show, params: { id: dir, format: "json" }
          expect(response).to be_success
        end
      end
      describe "HEAD" do
        it "succeeds" do
          head :show, params: { id: dir, format: "json" }
          expect(response).to be_success
        end
      end
    end

  end
end
