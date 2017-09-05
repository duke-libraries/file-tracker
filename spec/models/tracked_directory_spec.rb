require 'rails_helper'

RSpec.describe TrackedDirectory do

  describe "normalization of path" do
    subject { described_class.new(path: path) }
    describe "when it has a trailing slash" do
      let(:path) { File.join(fixture_path, "tracked_directory/") }
      before { subject.valid? }
      its(:path) { is_expected.to eq File.join(fixture_path, "tracked_directory") }
    end
  end

end
