require 'rails_helper'

module Api::V1
  RSpec.describe TrackedDirectoriesController do

    describe "index" do
      before  { TrackedDirectory.create!(path: fixture_path) }
      describe "GET" do
        it "JSON succeeds" do
          get :index, format: "json"
          expect(response).to be_success
        end
        it "CSV succeeds" do
          get :index, format: "csv"
          expect(response).to be_success
        end
      end
      describe "HEAD" do
        it "succeeds" do
          head :index, format: "json"
          expect(response).to be_success
        end
      end
    end

    describe "show" do
      let(:dir) { TrackedDirectory.create!(path: fixture_path) }
      describe "GET" do
        it "JSON succeeds" do
          get :show, params: { id: dir, format: "json" }
          expect(response).to be_success
        end
        it "CSV succeeds" do
          get :show, params: { id: dir, format: "csv" }
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
