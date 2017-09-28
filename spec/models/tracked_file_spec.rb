require 'rails_helper'

RSpec.describe TrackedFile do

  describe "scopes" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }

    describe "not_ok" do
      specify {
        file = TrackedFile.create(path: path)
        expect(TrackedFile.not_ok).not_to include file
      }
    end
    describe "ok" do
      specify {
        file = TrackedFile.create(path: path)
        expect(TrackedFile.ok).not_to include file
        file.fixity_status = FileTracker::Status::OK
        file.save!
        expect(TrackedFile.ok).to include file
      }
    end
    describe "modified" do
      specify {
        file = TrackedFile.create(path: path)
        expect(TrackedFile.modified).not_to include file
        file.fixity_status = FileTracker::Status::MODIFIED
        file.save!
        expect(TrackedFile.modified).to include file
      }
    end
    describe "missing" do
      specify {
        file = TrackedFile.create(path: path)
        expect(TrackedFile.missing).not_to include file
        file.fixity_status = FileTracker::Status::MISSING
        file.save!
        expect(TrackedFile.missing).to include file
      }
    end
    describe "error" do
      specify {
        file = TrackedFile.create(path: path)
        expect(TrackedFile.error).not_to include file
        file.fixity_status = FileTracker::Status::ERROR
        file.save!
        expect(TrackedFile.error).to include file
      }
    end
  end

  describe "validation" do
    let(:file) { Tempfile.create }
    let(:path) { file.path }
    after { File.unlink(path) if File.exist?(path) }

    subject { described_class.new(path: path) }
    it { is_expected.to be_valid }

    describe "existence violation" do
      before { File.unlink(path) }
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

  describe "it sets size before create" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    subject { described_class.create!(path: path) }
    its(:size) { is_expected.to eq 410226 }

    describe "unless size is present" do
      specify {
        expect_any_instance_of(described_class).not_to receive(:set_size)
        described_class.create!(path: path, size: 410226)
      }
    end
  end

  describe "it generates a SHA1 after create" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
    before { subject.reload }
    subject { described_class.create!(path: path) }
    its(:sha1) { is_expected.to eq sha1 }
  end

  describe "checking fixity" do
    subject {
      described_class.create!(path: path, size: size, sha1: sha1)
    }

    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:size) { 410226 }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }

    its(:check_fixity!) { is_expected.to be_ok }

    describe "when changed" do
      describe "when size has changed" do
        before do
          allow(File).to receive(:size).with(path) { 410225 }
        end
        its(:check_fixity!) { is_expected.to be_modified }
      end

      describe "when sha1 has changed" do
        before do
          allow_any_instance_of(FixityCheck).to receive(:calculate_sha1) { "37781031df4573b90ef045889b7da0ab2655bf75" }
        end
        its(:check_fixity!) { is_expected.to be_modified }
      end
    end

    describe "when missing" do
      let(:file) { Tempfile.create }
      let(:path) { file.path }

      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
      end

      specify {
        subject
        File.unlink(path)
        expect(subject.check_fixity!).to be_missing
      }
    end

    describe "when file is not readable" do
      let(:file) { Tempfile.create }
      let(:path) { file.path }

      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
      end

      after { File.unlink(path) }

      specify {
        subject
        FileUtils.chmod "u-r", path
        expect(subject.check_fixity!).to be_error
      }
    end
  end

end
