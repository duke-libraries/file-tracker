require 'rails_helper'

RSpec.describe TrackedFile do

  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
  let(:size) { 410226 }

  describe "tracked_directory" do
    subject { described_class.new(path: path) }
    let!(:dir) { TrackedDirectory.create!(path: fixture_path) }
    its(:tracked_directory) { is_expected.to eq dir }
  end

  describe "create" do
    describe "when it has not moved" do
      subject { described_class.new(path: path) }
      it "logs the file as ADDED" do
        expect(subject).to receive(:log).with(:added)
        subject.save!
      end
    end
    describe "when it has moved" do
      let(:dir) { TrackedDirectory.create!(path: Dir.mktmpdir) }
      let(:path1) { Tempfile.create("file-", dir.path).path }
      let(:path2) { Tempfile.create("file-", dir.path).path }
      subject { described_class.new(path: path1) }
      before do
        File.open(path2, "wb") { |f| f.write(SecureRandom.gen_random(100)) }
        described_class.create!(path: path2)
        FileUtils.mv(path2, path1)
      end
      it "logs the file as MOVED" do
        expect(subject).to receive(:log).with(:moved, "Probably moved from: #{path2}")
        subject.save!
      end
      after { FileUtils.remove_entry_secure(dir.path) }
    end
    describe "size calculation" do
      describe "when size is provided" do
        subject { described_class.new(path: path, size: size) }
        it "does not set the size" do
          expect { subject.save! }.not_to change(subject, :size)
        end
      end
      describe "when size is not provided" do
        subject { described_class.new(path: path) }
        it "sets the size" do
          expect { subject.save! }.to change(subject, :size).to(size)
        end
      end
      describe "sha1 calculation" do
        describe "when sha1 is provided" do
          subject { described_class.new(path: path, sha1: sha1) }
          it "does not set the sha1" do
            expect { subject.save! }.not_to change(subject, :sha1)
          end
        end
        describe "when sha1 is not provided" do
          subject { described_class.new(path: path) }
          it "sets the sha1" do
            expect { subject.save! }.to change(subject, :sha1).to(sha1)
          end
        end
      end
    end
  end # create

  describe "update" do
    describe "SHA1 re-calculation" do
      describe "when SHA1 is present" do
        subject { described_class.create(path: path, sha1: sha1) }
        it "does not re-calculate a SHA1" do
          expect { subject.touch; subject.save! }.not_to change(subject, :sha1)
        end
      end
      describe "when a SHA1 is not present" do
        subject { described_class.create!(path: path) }
        before { subject.sha1 = nil }
        it "calculates a SHA1" do
          expect { subject.save! }.to change(subject, :sha1).from(nil).to(sha1)
        end
      end
    end
  end

  describe "#destroy" do
    describe "when the file has not moved" do
      subject { described_class.create!(path: path, size: size, sha1: sha1) }
      it "logs the file as REMOVED" do
        expect(subject).to receive(:log).with(:removed)
        subject.destroy
      end
    end
    describe "when the file has moved" do
      let(:dir) { TrackedDirectory.create!(path: Dir.mktmpdir) }
      let(:path1) { Tempfile.create("file-", dir.path).path }
      let(:path2) { Tempfile.create("file-", dir.path).path }
      subject { described_class.create!(path: path1) }
      before do
        File.open(path1, "wb") { |f| f.write(SecureRandom.gen_random(100)) }
        subject.touch
        FileUtils.mv(path1, path2)
        described_class.create!(path: path2)
      end
      it "logs the file as MOVED" do
        expect(subject).to receive(:log).with(:moved, "Probably moved to: #{path2}")
        subject.destroy
      end
      after { FileUtils.remove_entry_secure(dir.path) }
    end
  end

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

  describe "validation" do
    subject { described_class.new(path: path) }
    describe "with a directory path" do
      let(:path) { fixture_path }
      it { is_expected.to be_invalid }
    end
    describe "with a non-existent path" do
      let(:path) { File.join(Dir.tmpdir, Dir::Tmpname.make_tmpname("foo", nil)) }
      it { is_expected.to be_invalid }
    end
    describe "with a symlink" do
      let(:target) { File.join(fixture_path, "nypl.jpg") }
      let(:dir) { Dir.mktmpdir }
      let(:path) { File.join(dir, "nypl.jpg") }
      before { FileUtils.ln_s(target, path) }
      after { FileUtils.rm_r(dir) if Dir.exist?(dir) }
      it { is_expected.to be_invalid }
    end
    describe "with an existing file" do
      let(:file) { Tempfile.create("foo") }
      let(:path) { file.path }
      before do
        File.open(path, "wb") { |f| f.write(SecureRandom.gen_random(100)) }
      end
      after { File.unlink(path) if File.exist?(path) }
      it { is_expected.to be_valid }
      describe "that is not readable" do
        before { FileUtils.chmod "u-r", path }
        it { is_expected.to be_invalid }
      end
      describe "that is not unique" do
        before { described_class.create!(path: path) }
        it { is_expected.to be_invalid }
      end
      describe "that is empty" do
        before { File.truncate(path, 0) }
        it { is_expected.to be_invalid }
      end
    end
  end

  describe "track!" do
    describe "with a new record" do
      subject { described_class.new(path: path) }
      it "saves the record" do
        expect { subject.track! }.to change(subject, :new_record?).to(false)
      end
    end
    describe "with an existing record" do
      subject { described_class.create!(path: path, size: size, sha1: sha1) }
      describe "when the file size has not changed" do
        it "touches the record" do
          expect { subject.track! }.to change(subject, :updated_at)
        end
      end
      describe "when the file size has changed" do
        before do
          allow(File).to receive(:size).with(path) { 410225 }
        end
        it "changes the size" do
          expect { subject.track! }.to change(subject, :size).to(410225)
        end
        it "logs a modification" do
          expect(subject).to receive(:log).with(:modified, "SHA1 was: #{sha1}")
          subject.track!
        end
      end # file size has changed
      describe "when the file is missing" do
        it "destroys the file record" do
          allow(File).to receive(:size).with(path).and_raise(Errno::ENOENT)
          expect(subject.track!).to be_destroyed
        end
      end
    end # existing record
  end # track!

  describe "checking fixity" do
    subject {
      described_class.create!(path: path, size: size, sha1: sha1)
    }
    it "changes the fixity checked date" do
      expect { subject.check_fixity! }.to change(subject, :fixity_checked_at)
    end
    describe "when changed" do
      describe "when size has changed" do
        before do
          allow(File).to receive(:size).with(path) { 410225 }
        end
        it "changes the size of the record" do
          expect { subject.check_fixity! }.to change(subject, :size).to(410225)
        end
      end
      describe "when sha1 has changed" do
        before do
          allow_any_instance_of(FixityCheck).to receive(:calculate_sha1) { "37781031df4573b90ef045889b7da0ab2655bf75" }
        end
        it "changes the sha1 of the record" do
          expect { subject.check_fixity! }.to change(subject, :sha1).to("37781031df4573b90ef045889b7da0ab2655bf75")
        end
      end
    end
    describe "when missing" do
      let(:dir) { Dir.mktmpdir }
      let(:file) { Tempfile.create("foo", dir) }
      let(:path) { file.path }
      before do
        file.binmode
        file.write File.read(File.join(fixture_path, "nypl.jpg"))
        file.close
        subject
        File.unlink(path)
      end
      it "destroys the record" do
        expect(subject.check_fixity!).to be_destroyed
      end
    end
    describe "when file is not readable" do
      let(:file) { Tempfile.create("foo") }
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
        expect { subject.check_fixity! }.not_to change { subject }
      }
      it "doesn't track the error as a change" do
        expect { subject.check_fixity! }.not_to change { subject }
      end
    end
  end

  describe "#large?" do
    before do
      allow(FileTracker).to receive(:large_file_threshhold) { 200 }
    end
    describe "when size is nil" do
      subject { described_class.new(path: path) }
      it { is_expected.to_not be_large }
    end
    describe "when size is not nil" do
      let(:path) { Tempfile.create("foo").path }
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
