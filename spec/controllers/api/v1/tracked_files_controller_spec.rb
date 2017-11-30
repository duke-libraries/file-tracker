require 'rails_helper'

module Api::V1
  RSpec.describe TrackedFilesController do

    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
    let(:md5) { "57a88467c003f53d316a92e8896833b0" }
    let(:size) { 410226 }

    describe "show" do
      let(:file) { TrackedFile.create!(path: path, sha1: sha1, md5: md5, size: size) }
      describe "GET" do
        it "succeeds" do
          get :show, params: { id: file, format: "json" }
          expect(response).to be_success
        end
      end
      describe "HEAD" do
        it "succeeds" do
          head :show, params: { id: file, format: "json" }
          expect(response).to be_success
        end
      end
    end

    describe "create" do
      it "succeeds with a valid file" do
        post :create, params: { path: path, sha1: sha1, md5: md5, size: size }
        expect(response.response_code).to eq 201
      end
      it "is forbidden with an invalid file" do
        post :create, params: { path: "/foo/bar", sha1: sha1, md5: md5, size: size }
        expect(response.response_code).to eq 403
      end
    end

  end
end
