require 'rails_helper'

RSpec.describe TrackedFile do

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

  describe "it generates fixity after create" do
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:md5) { "57a88467c003f53d316a92e8896833b0" }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
    before { subject.reload }
    describe "when no fixity info is present" do
      subject { described_class.create!(path: path) }
      its(:md5) { is_expected.to eq md5 }
      its(:sha1) { is_expected.to eq sha1 }
    end
    describe "when only md5 is present" do
      subject { described_class.create!(path: path, md5: md5) }
      its(:sha1) { is_expected.to eq sha1 }
    end
    describe "when only sha1 is present" do
      subject { described_class.create!(path: path, sha1: sha1) }
      its(:md5) { is_expected.to eq md5 }
    end
    describe "otherwise, fixity is not generated" do
      subject { described_class.create!(path: path, md5: md5, sha1: sha1) }
      it { is_expected.not_to receive(:generate_fixity) }
    end
  end

  describe "checking fixity" do
    subject {
      described_class.create!(path: path, size: size, md5: md5, sha1: sha1)
    }

    let(:path) { File.join(fixture_path, "nypl.jpg") }
    let(:size) { 410226 }
    let(:md5) { "57a88467c003f53d316a92e8896833b0" }
    let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }

    its(:check_fixity) { is_expected.to be_ok }

    describe "when changed" do
      describe "when size has changed" do
        before do
          allow(subject).to receive(:calculate_size) { 410225 }
          expect(subject).not_to receive(:calculate_fixity)
        end
        its(:check_fixity) { is_expected.to be_altered }
      end

      describe "when md5 has changed" do
        let(:fixity) { Fixity.new("57a88467c003f53d316a92e8896833b1", sha1) }
        before do
          allow(subject).to receive(:calculate_fixity) { fixity }
        end
        its(:check_fixity) { is_expected.to be_altered }
      end

      describe "when sha1 has changed" do
        let(:fixity) { Fixity.new(md5, "37781031df4573b90ef045889b7da0ab2655bf75") }
        before do
          allow(subject).to receive(:calculate_fixity) { fixity }
        end
        its(:check_fixity) { is_expected.to be_altered }
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
        expect(subject.check_fixity).to be_missing
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
        expect(subject.check_fixity).to be_error
      }
    end
  end

end
