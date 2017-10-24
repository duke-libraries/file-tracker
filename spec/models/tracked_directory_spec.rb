require 'rails_helper'

RSpec.describe TrackedDirectory do

  describe "file tracking" do
    let(:path) { fixture_path }
    subject { described_class.create!(path: path) }
    before { subject.track! }
    specify {
      file = subject.tracked_files.first
      expect(file.size).to eq 410226
      expect(file.path).to eq File.join(path, "nypl.jpg")
    }
  end

  describe "validation" do
    subject { described_class.new(path: path) }
    let(:path) { Dir.mktmpdir }
    after { Dir.rmdir(path) if Dir.exist?(path) }

    describe "existence violation" do
      before { Dir.rmdir(path) }
      it { is_expected.to be_invalid }
    end

    describe "readable violation" do
      before { FileUtils.chmod "u-r", path }
      it { is_expected.to be_invalid }
    end

    describe "uniqueness violation" do
      before { described_class.create!(path: path) }
      it { is_expected.to be_invalid }
    end
  end

  describe "normalization of path" do
    subject { described_class.new(path: path) }
    let(:path) { "#{fixture_path}/" }
    before { subject.valid? }
    its(:path) { is_expected.to eq fixture_path }
  end

end
