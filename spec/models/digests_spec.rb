require 'rails_helper'

RSpec.describe Digests do

  subject { described_class.new(path) }

  let(:path) { File.join(fixture_path, "tracked_directory", "nypl.digitalcollections.5fc6edd0-00a5-0133-7884-58d385a7bbd0.001.w.jpg") }

  its(:md5) { is_expected.to eq "57a88467c003f53d316a92e8896833b0" }

  its(:sha1) { is_expected.to eq "37781031df4573b90ef045889b7da0ab2655bf74" }

  it { is_expected.to eq described_class.new(path, "57a88467c003f53d316a92e8896833b0", "37781031df4573b90ef045889b7da0ab2655bf74") }

  it { is_expected.not_to eq described_class.new(path, "foo", "37781031df4573b90ef045889b7da0ab2655bf74") }

  it { is_expected.not_to eq described_class.new(path, "57a88467c003f53d316a92e8896833b0", "foo") }

  it { is_expected.not_to eq described_class.new("foo", "57a88467c003f53d316a92e8896833b0", "37781031df4573b90ef045889b7da0ab2655bf74") }

end
