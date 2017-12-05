require 'rails_helper'

module Api::V1
  RSpec.describe TrackedFilesController do

    let(:dir) { TrackedDirectory.create(path: fixture_path) }
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
    let(:md5) { "57a88467c003f53d316a92e8896833b0" }
    let(:size) { 410226 }

    describe "show" do
      let(:file) { TrackedFile.create!(tracked_directory: dir, path: path, sha1: sha1, md5: md5, size: size) }
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

  end
end
