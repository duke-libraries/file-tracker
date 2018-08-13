require 'rails_helper'

RSpec.describe TrackedDirectory do

  describe "file tracking" do

    let(:path) { fixture_path }
    subject { described_class.create!(path: path) }

    describe "normal operation" do
      before { subject.track! }

      it "tracks files" do
        file = File.join(subject.path, "nypl.jpg")
        expect(subject.tracked_files.pluck(:path)).to include(file)
      end
      it "tracks subdirectories" do
        file = File.join(subject.path, "subdir", "lorem_ipsum.txt")
        expect(subject.tracked_files.pluck(:path)).to include(file)
      end
      it "includes empty files" do
        empty_file = File.join(subject.path, "empty.txt")
        expect(subject.tracked_files.pluck(:path)).to include(empty_file)
      end
    end

    describe "error handling" do
      let(:file) { File.join(subject.path, "nypl.jpg") }

      describe "certain errors" do
        before do
          allow(File).to receive(:size) { 100 }
          allow(File).to receive(:size).with(file).and_raise(Errno::ENOENT)
        end
        it "rescues from the error" do
          expect { subject.track! }.not_to raise_error
        end
        it "logs the error" do
          expect(Rails.logger).to receive(:error)
          subject.track!
        end
      end

      describe "other error" do
        before do
          allow(File).to receive(:size) { 100 }
          allow(File).to receive(:size).with(file).and_raise(StandardError)
        end
        it "raise the error" do
          expect { subject.track! }.to raise_error(StandardError)
        end
      end
    end
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
