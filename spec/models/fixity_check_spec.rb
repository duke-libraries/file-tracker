require 'rails_helper'

RSpec.describe FixityCheck do

  subject { described_class.new(tracked_file: tracked_file) }

  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:tracked_file) { TrackedFile.create(path: path, sha1: sha1, size: size) }
  let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
  let(:size) { 410226 }

  describe "updating the tracked file" do
    it "updates the fixity_checked_at date" do
      expect { subject.execute }.to change(tracked_file, :fixity_checked_at).from(nil)
    end
    it "updates the status" do
      allow(File).to receive(:size).with(path) { 410225 }
      expect { subject.execute }.to change(tracked_file, :status).to(FileTracker::Status::MODIFIED)
    end
  end

  describe "check_size" do
    it "sets the size attribute" do
      expect { subject.check_size }.to change(subject, :size).to(size)
    end
    describe "when size has changed" do
      it "raises an exception" do
        allow(File).to receive(:size).with(tracked_file.path) { 410225 }
        expect { subject.check_size }.to raise_error(FileTracker::ModifiedFileError)
      end
    end
    describe "when size has not changed" do
      it "does not raise an exception" do
        expect { subject.check_size }.not_to raise_error
      end
    end
  end

  describe "check_sha1" do
    it "sets the sha1 attribute" do
      expect { subject.check_sha1 }.to change(subject, :sha1).to("37781031df4573b90ef045889b7da0ab2655bf74")
    end
    describe "when sha1 has changed" do
      it "raises an exception" do
        allow(subject).to receive(:calculate_digest).with(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf73" }
        expect { subject.check_sha1 }.to raise_error(FileTracker::ModifiedFileError)
      end
    end
    describe "when sha1 has not changed" do
      it "does not raise an exception" do
        expect { subject.check_sha1 }.not_to raise_error
      end
    end
  end

  describe "check" do
    describe "when the size has not changed" do
      describe "and the sha1 has not changed" do
        it "sets the status to OK" do
          expect { subject.check }.to change(subject, :status).to(FileTracker::Status::OK)
        end
      end
      describe "and the sha1 has changed" do
        let(:new_sha1) { "37781031df4573b90ef045889b7da0ab2655bf73" }
        before do
          allow(subject).to receive(:calculate_digest).with(:sha1) { new_sha1 }
          subject.check
        end
        it { is_expected.to be_modified }
        its(:message) { is_expected.to eq "Expected SHA1 {#{sha1}}; actual SHA1 {#{new_sha1}}." }
      end
    end
    describe "when the size has changed" do
      let(:new_size) { 410225 }
      before do
        allow(File).to receive(:size).with(tracked_file.path) { new_size }
      end
      it "does not check the sha1" do
        expect(subject).not_to receive(:check_sha1)
        subject.check
      end
      describe "after size check" do
        before { subject.check }
        it { is_expected.to be_modified }
        its(:message) { is_expected.to eq "Expected size: #{size}; actual size: #{new_size}." }
      end
    end
    describe "when the file is missing" do
      let(:file) { Tempfile.create("foo") }
      let(:tracked_file) { TrackedFile.create(path: file.path) }
      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
        tracked_file
        File.unlink(file.path)
      end
      it "sets the status to MISSING" do
        expect { subject.check }.to change(subject, :status).to(FileTracker::Status::MISSING)
      end
    end
    describe "when the user lacks permission to read the file" do
      let(:file) { Tempfile.create("foo") }
      let(:tracked_file) { TrackedFile.create(path: file.path) }
      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
        tracked_file
        FileUtils.chmod "u-r", file.path
      end
      after { File.unlink(file.path) }
      it "sets the status to ERROR" do
        expect { subject.check }.to change(subject, :status).to(FileTracker::Status::ERROR)
      end
    end
  end

  describe "status value methods" do
    describe "when status is nil" do
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when status is OK" do
      before { subject.status = FileTracker::Status::OK }
      it { is_expected.to be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when status is MODIFIED" do
      before { subject.status = FileTracker::Status::MODIFIED }
      it { is_expected.to_not be_ok }
      it { is_expected.to be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when status is MISSING" do
      before { subject.status = FileTracker::Status::MISSING }
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when status is ERROR" do
      before { subject.status = FileTracker::Status::ERROR }
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to be_error }
    end
    describe "ok!" do
      specify {
        expect { subject.ok! }.to change(subject, :status).to(FileTracker::Status::OK)
      }
    end
    describe "modified!" do
      specify {
        expect { subject.modified! }.to change(subject, :status).to(FileTracker::Status::MODIFIED)
      }
    end
    describe "missing!" do
      specify {
        expect { subject.missing! }.to change(subject, :status).to(FileTracker::Status::MISSING)
      }
    end
    describe "error!" do
      specify {
        expect { subject.error! }.to change(subject, :status).to(FileTracker::Status::ERROR)
      }
    end
  end

end
