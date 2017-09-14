require 'rails_helper'

RSpec.describe TrackedFile do

  subject do
    described_class.new(path: path, md5: md5, sha1: sha1, size: size)
  end

  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:md5) { "57a88467c003f53d316a92e8896833b0" }
  let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
  let(:size) { 410226 }

  describe "fixity check" do
    its(:fixity_check) { is_expected.to eq 0 }

    describe "changed (size)" do
      before do
        allow(File).to receive(:size).with(path) { 410225 }
      end
      its(:fixity_check) { is_expected.to eq 1 }
    end

    describe "changed (md5)" do
      let(:fixity) { Fixity.new(path, size, "57a88467c003f53d316a92e8896833b1", sha1) }
      before do
        allow(subject).to receive(:calculate_fixity) { fixity }
      end
      its(:fixity_check) { is_expected.to eq 1 }
    end

    describe "changed (sha1)" do
      let(:fixity) { Fixity.new(path, size, md5, "37781031df4573b90ef045889b7da0ab2655bf75") }
      before do
        allow(subject).to receive(:calculate_fixity) { fixity }
      end
      its(:fixity_check) { is_expected.to eq 1 }
    end

    describe "missing (size)" do
      before do
        allow(File).to receive(:size).with(path).and_raise(Errno::ENOENT)
      end
      its(:fixity_check) { is_expected.to eq 2 }
    end

    describe "missing (open)" do
      before do
        allow(File).to receive(:open).with(path, "rb").and_raise(Errno::ENOENT)
      end
      its(:fixity_check) { is_expected.to eq 2 }
    end
  end

end
