require 'rails_helper'

RSpec.describe Fixity do

  describe "calculate" do
    subject { described_class.calculate(path) }
    let(:path) { File.join(fixture_path, "nypl.jpg") }
    its(:md5) { is_expected.to eq "57a88467c003f53d316a92e8896833b0" }
    its(:sha1) { is_expected.to eq "37781031df4573b90ef045889b7da0ab2655bf74" }
  end

  describe "completeness" do
    subject { described_class.new(md5, sha1) }

    describe "both are nil" do
      let(:md5) { nil }
      let(:sha1) { nil }
      it { is_expected.to be_incomplete }
      it { is_expected.not_to be_complete }
    end

    describe "only md5 is nil" do
      let(:md5) { nil }
      let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
      it { is_expected.to be_incomplete }
      it { is_expected.not_to be_complete }
    end

    describe "neither is nil" do
      let(:md5) { "57a88467c003f53d316a92e8896833b0" }
      let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
      it { is_expected.not_to be_incomplete }
      it { is_expected.to be_complete }
    end

    describe "only sha1 is nil" do
      let(:md5) { "57a88467c003f53d316a92e8896833b0" }
      let(:sha1) { nil }
      it { is_expected.to be_incomplete }
      it { is_expected.not_to be_complete }
    end
  end

end
