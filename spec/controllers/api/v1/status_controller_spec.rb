require 'rails_helper'

module Api::V1
  RSpec.describe StatusController, status: true do

    describe "index" do
      subject { get :index, format: 'json' }

      it { is_expected.to be_successful }

      describe "response content" do
        before { get :index, format: 'json' }
        let(:body) { JSON.parse(response.body) }

        describe "meta" do
          subject { body["meta"] }

          its(["version"]) { is_expected.to eq FileTracker::VERSION }
        end

        describe "data" do
          subject { body["data"] }

          its(:keys) { are_expected.to contain_exactly("queues", "directories", "files") }
        end
      end
    end

  end
end
