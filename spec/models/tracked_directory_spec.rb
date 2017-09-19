require 'rails_helper'

RSpec.describe TrackedDirectory do

  describe ".track!" do
    subject { described_class.track!(fixture_path) }
    specify {
      file = subject.tracked_files.where(path: File.join(fixture_path, "nypl.jpg")).first
      expect(file.size).to eq 410226
      expect(file.md5).to eq "57a88467c003f53d316a92e8896833b0"
      expect(file.sha1).to eq "37781031df4573b90ef045889b7da0ab2655bf74"
    }
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
