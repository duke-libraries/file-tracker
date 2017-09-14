require 'rails_helper'

RSpec.describe TrackedDirectory do

  describe ".track!" do
    subject { described_class.track!(fixture_path) }
    its(:tracked_files) { is_expected.to be_present }
  end

  describe "normalization of path" do
    subject { described_class.new(path: path) }
    describe "when it has a trailing slash" do
      let(:path) { "#{fixture_path}/" }
      before { subject.valid? }
      its(:path) { is_expected.to eq fixture_path }
    end
  end

end
