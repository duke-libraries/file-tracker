require 'rails_helper'

RSpec.describe TrackedFile do

  describe "create" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    describe "size calculation" do
      describe "when size is provided" do
        it "does not set the size" do
          expect_any_instance_of(described_class).not_to receive(:set_size)
          described_class.create!(path: path, size: 410226)
        end
      end
      describe "when size is not provided" do
        it "sets the size" do
          expect_any_instance_of(described_class).to receive(:set_size).and_call_original
          file = described_class.create!(path: path)
          expect(file.size).to eq 410226
        end
      end
    end
    describe "SHA1 generation" do
      let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
      describe "when a SHA1 is provided" do
        it "does not generate a SHA1" do
          expect_any_instance_of(described_class).not_to receive(:generate_sha1)
          described_class.create!(path: path, sha1: sha1)
        end
      end
      describe "when a SHA1 is not provided" do
        it "generates a SHA1" do
          expect_any_instance_of(described_class).to receive(:generate_sha1).and_call_original
          file = described_class.create!(path: path)
          file.reload
          expect(file.sha1).to eq sha1
        end
      end
    end
  end

  describe "class methods" do
    describe ".track!" do
      before do
        @dir = Dir.mktmpdir
        @file1 = Tempfile.create("file-", @dir)
        File.open(@file1.path, "wb") { |f| f.write(SecureRandom.gen_random(1000)) }
        described_class.create(path: @file1.path, size: 1000)
        @file2 = Tempfile.create("file-", @dir)
        File.open(@file2.path, "wb") { |f| f.write(SecureRandom.gen_random(2000)) }
        @file3 = Tempfile.create("file-", @dir)
        File.open(@file3.path, "wb") { |f| f.write(SecureRandom.gen_random(3000)) }
      end
      after { FileUtils.remove_entry_secure(@dir) }
      it "checks the size of each previously tracked file path" do
        expect_any_instance_of(described_class).to receive(:check_size!).once
        described_class.track!(@file1.path, @file2.path, @file3.path)
      end
      it "creates tracked files for new paths" do
        expect { described_class.track!(@file1.path, @file2.path, @file3.path) }.to change(TrackedFile, :count).by(2)
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
  end

  describe "fixity status value methods" do
    subject { described_class.new(path: path) }
    let(:path) { File.join(fixture_path, "nypl.jpg") }

    describe "when fixity status is nil" do
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when fixity status is OK" do
      before { subject.fixity_status = FileTracker::Status::OK }
      it { is_expected.to be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when fixity status is MODIFIED" do
      before { subject.fixity_status = FileTracker::Status::MODIFIED }
      it { is_expected.to_not be_ok }
      it { is_expected.to be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when fixity status is MISSING" do
      before { subject.fixity_status = FileTracker::Status::MISSING }
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to be_missing }
      it { is_expected.to_not be_error }
    end
    describe "when fixity status is ERROR" do
      before { subject.fixity_status = FileTracker::Status::ERROR }
      it { is_expected.to_not be_ok }
      it { is_expected.to_not be_modified }
      it { is_expected.to_not be_missing }
      it { is_expected.to be_error }
    end
    describe "ok!" do
      specify {
        expect { subject.ok! }.to change(subject, :fixity_status).to(FileTracker::Status::OK)
      }
    end
    describe "modified!" do
      specify {
        expect { subject.modified! }.to change(subject, :fixity_status).to(FileTracker::Status::MODIFIED)
      }
    end
    describe "missing!" do
      specify {
        expect { subject.missing! }.to change(subject, :fixity_status).to(FileTracker::Status::MISSING)
      }
    end
    describe "error!" do
      specify {
        expect { subject.error! }.to change(subject, :fixity_status).to(FileTracker::Status::ERROR)
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
        describe "and the fixity status is MODIFIED" do
          before { subject.modified! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
        describe "and the fixity status is MISSING" do
          before { subject.missing! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
        describe "and the fixity status is OK" do
          before { subject.ok! }
          it "tracks the change" do
            allow(subject).to receive(:calculate_size) { 410225 }
            subject.track!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_modification
          end
        end
        describe "and the fixity status is ERROR" do
          before { subject.error! }
          it "does nothing" do
            expect { subject.track! }.not_to change { subject.tracked_changes.count }
          end
        end
        describe "and the fixity status is nil" do
          it "tracks the change" do
            allow(subject).to receive(:calculate_size) { 410225 }
            subject.track!
            tracked_change = subject.tracked_changes.last
            expect(tracked_change).to be_modification
          end
        end
      end
      describe "when the file is missing" do
        # TODO
      end
      describe "when there is a permissions error" do
        # TODO
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
      it "sets the fixity_status to MISSING" do
        expect { subject.check_fixity! }.to change(subject, :fixity_status).to(FileTracker::Status::MISSING)
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

end
