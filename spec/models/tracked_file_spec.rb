require 'rails_helper'

RSpec.describe TrackedFile do

  describe "create" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    describe "size calculation" do
      describe "when size is provided" do
        subject { described_class.new(path: path, size: 410226) }
        it "does not set the size" do
          expect(subject).not_to receive(:size=)
          subject.save!
        end
      end
      describe "when size is not provided" do
        subject { described_class.new(path: path) }
        it "sets the size" do
          expect(subject).to receive(:size=).and_call_original
          subject.save!
          expect(subject.size).to eq 410226
        end
      end
    end
    describe "SHA1 generation" do
      let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
      describe "when a SHA1 is provided" do
        subject { described_class.new(path: path, sha1: sha1) }
        it "does not try to generate a SHA1" do
          expect(subject).not_to receive(:generate_sha1)
          subject.save!
        end
        describe "when explicitly calling #generate_sha1" do
          before { subject.save! }
          it "does not generate a SHA1" do
            expect(subject).not_to receive(:sha1=)
            subject.generate_sha1
          end
        end
      end
      describe "when a SHA1 is not provided" do
        subject { described_class.new(path: path) }
        it "generates a SHA1" do
          subject.save!
          subject.reload
          expect(subject.sha1).to eq sha1
        end
        describe "when set_sha1 encounters a file not found error" do
          it "tracks a deletion" do
            expect_any_instance_of(described_class).to receive(:set_sha1).and_raise(Errno::ENOENT)
            subject.save!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_deletion
          end
          it "marks the file as MISSING" do
            expect_any_instance_of(described_class).to receive(:set_sha1).and_raise(Errno::ENOENT)
            subject.save!
            subject.reload
            expect(subject).to be_missing
          end
        end
      end
    end
  end

  describe "class methods" do
    describe ".track!" do
      let(:dir) { Dir.mktmpdir }
      let(:path1) { Tempfile.create("file-", dir).path }
      let(:path2) { Tempfile.create("file-", dir).path }
      let(:path3) { Tempfile.create("file-", dir).path }
      before do
        File.open(path1, "wb") { |f| f.write(SecureRandom.gen_random(1000)) }
        described_class.create(path: path1, size: 1000)
        File.open(path2, "wb") { |f| f.write(SecureRandom.gen_random(2000)) }
        File.open(path3, "wb") { |f| f.write(SecureRandom.gen_random(3000)) }
      end
      after { FileUtils.remove_entry_secure(dir) }
      it "checks the size of each previously tracked file path" do
        expect_any_instance_of(described_class).to receive(:check_size!).once
        described_class.track!(path1, path2, path3)
      end
      it "creates tracked files for new paths" do
        expect { described_class.track!(path1, path2, path3) }.to change(TrackedFile, :count).by(2)
      end
    end

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
          file.status = FileTracker::Status::MODIFIED
          file.save!
          expect(TrackedFile.ok).not_to include file
          file.status = FileTracker::Status::OK
          file.save!
          expect(TrackedFile.ok).to include file
        }
      end
      describe "modified" do
        specify {
          file = TrackedFile.create(path: path)
          expect(TrackedFile.modified).not_to include file
          file.status = FileTracker::Status::MODIFIED
          file.save!
          expect(TrackedFile.modified).to include file
        }
      end
      describe "missing" do
        specify {
          file = TrackedFile.create(path: path)
          expect(TrackedFile.missing).not_to include file
          file.status = FileTracker::Status::MISSING
          file.save!
          expect(TrackedFile.missing).to include file
        }
      end
      describe "error" do
        specify {
          file = TrackedFile.create(path: path)
          expect(TrackedFile.error).not_to include file
          file.status = FileTracker::Status::ERROR
          file.save!
          expect(TrackedFile.error).to include file
        }
      end
    end
  end

  describe "status value methods" do
    subject { described_class.new(path: path) }
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    describe "when status is OK" do
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
        subject.status = FileTracker::Status::MODIFIED
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

  describe "fixity checking boolean methods" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    subject { described_class.new(path: path) }
    describe "fixity_checkable?" do
      it { is_expected.to_not be_fixity_checkable }
      describe "new record with a SHA1" do
        before { subject.sha1 = "37781031df4573b90ef045889b7da0ab2655bf74" }
        it { is_expected.to_not be_fixity_checkable }
      end
      describe "persisted, after SHA1 generation" do
        before do
          subject.save!
          subject.reload
        end
        it { is_expected.to be_fixity_checkable }
        describe "and status is not OK" do
          before do
            subject.modified!
            subject.save!
          end
          it { is_expected.to_not be_fixity_checkable }
        end
      end
    end
    describe "fixity_checked?" do
      it { is_expected.to_not be_fixity_checked }
      describe "persisted, after SHA1 generation" do
        before do
          subject.save!
          subject.reload
        end
        it { is_expected.to_not be_fixity_checked }
        describe "after a fixity check" do
          before do
            subject.check_fixity!
            subject.reload
          end
          it { is_expected.to be_fixity_checked }
        end
      end
    end
    describe "fixity_check_due?" do
      it { is_expected.to_not be_fixity_check_due }
      describe "persisted, after SHA1 generation" do
        before do
          subject.save!
          subject.reload
        end
        it { is_expected.to_not be_fixity_check_due }
        describe "after a fixity check" do
          before do
            subject.check_fixity!
            subject.reload
          end
          it { is_expected.to_not be_fixity_check_due }
          describe "when the last fixity happened before the cutoff date" do
            before do
              allow(described_class).to receive(:fixity_check_cutoff_date) { DateTime.now }
            end
            it { is_expected.to be_fixity_check_due }
          end
        end
      end
    end
    describe "check_fixity?" do
      its(:check_fixity?) { is_expected.to be false }
      describe "fixity checkable and not checked" do
        before do
          subject.save!
          subject.reload
        end
        its(:check_fixity?) { is_expected.to be true }
        describe "and status is not OK" do
          before do
            subject.modified!
            subject.save!
          end
          its(:check_fixity?) { is_expected.to be false }
        end
        describe "after a fixity check" do
          before do
            subject.check_fixity!
            subject.reload
          end
          its(:check_fixity?) { is_expected.to be false }
          describe "when the last fixity happened before the cutoff date" do
            before do
              allow(described_class).to receive(:fixity_check_cutoff_date) { DateTime.now }
            end
            its(:check_fixity?) { is_expected.to be true }
          end
        end
      end
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

  describe "track!" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    describe "with a new record" do
      subject { described_class.new(path: path) }
      it "saves the record" do
        expect { subject.track! }.to change(subject, :new_record?).to(false)
      end
    end
    describe "with an existing record" do
      subject { described_class.create!(path: path, size: 410226) }
      describe "when the file size has not changed" do
        it "does nothing" do
          expect { subject.track! }.not_to change { subject.tracked_changes.count }
        end
      end
      describe "when the file size has changed" do
        describe "and the status is MODIFIED" do
          before { subject.modified! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
        describe "and the status is MISSING" do
          before { subject.missing! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
        describe "and the status is OK" do
          it "tracks the change" do
            allow(subject).to receive(:calculate_size) { 410225 }
            subject.track!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_modification
          end
        end
        describe "and the status is ERROR" do
          before { subject.error! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
      end # file size has changed
      describe "when the file is missing" do
        it "tracks a deletion" do
          allow(File).to receive(:size).with(path).and_raise(Errno::ENOENT)
          subject.track!
          tracked_change = subject.tracked_changes.last
          expect(tracked_change).to be_deletion
        end
      end
    end # existing record
  end # track!

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
        describe "tracking the modification change" do
          specify {
            subject.check_fixity!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_modification
            expect(tracked_change.size).to eq 410225
            expect(tracked_change.sha1).to be_nil
          }
        end
      end
      describe "when sha1 has changed" do
        before do
          allow_any_instance_of(FixityCheck).to receive(:calculate_sha1) { "37781031df4573b90ef045889b7da0ab2655bf75" }
        end
        its(:check_fixity!) { is_expected.to be_modified }
        describe "tracking the modification change" do
          specify {
            subject.check_fixity!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_modification
            expect(tracked_change.size).to eq subject.size
            expect(tracked_change.sha1).to eq "37781031df4573b90ef045889b7da0ab2655bf75"
          }
        end
      end
    end
    describe "when missing" do
      let(:file) { Tempfile.create }
      let(:path) { file.path }
      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
        subject
        File.unlink(path)
      end
      it "sets the status to MISSING" do
        expect { subject.check_fixity! }.to change(subject, :status).to(FileTracker::Status::MISSING)
      end
      describe "tracking the deletion" do
        specify {
          subject.check_fixity!
          tracked_change = subject.tracked_changes.last
          expect(tracked_change).to be_deletion
          expect(tracked_change.size).to be_nil
          expect(tracked_change.sha1).to be_nil
        }
      end
    end
    describe "when file is not readable" do
      let(:file) { Tempfile.create }
      let(:path) { file.path }
      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
        subject
        FileUtils.chmod "u-r", path
      end
      after { File.unlink(path) }
      specify {
        expect(subject.check_fixity!).to be_error
      }
      it "doesn't track the error as a change" do
        expect { subject.check_fixity! }.not_to change(subject.tracked_changes, :count)
      end
    end
  end

  describe "#large?" do
    before do
      allow(FileTracker.configuration).to receive(:large_file_threshhold) { 200 }
    end
    describe "when size is nil" do
      let(:path) { File.join(fixture_path, "nypl.jpg") }
      subject { described_class.new(path: path) }
      it { is_expected.to_not be_large }
    end
    describe "when size is not nil" do
      let(:path) { Tempfile.create.path }
      subject { described_class.new(path: path, size: size) }
      before do
        File.open(path, "wb") { |f| f.write(SecureRandom.gen_random(size)) }
      end
      after { File.unlink(path) }
      describe "when size < large file threshhold" do
        let(:size) { 100 }
        it { is_expected.to_not be_large }
      end
      describe "when size == large file threshhold" do
        let(:size) { 200 }
        it { is_expected.to be_large }
      end
      describe "when size > large file threshhold" do
        let(:size) { 300 }
        it { is_expected.to be_large }
      end
    end
  end

end
