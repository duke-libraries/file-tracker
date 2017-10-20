require 'rails_helper'

RSpec.describe RetryOnError do

  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:block) { proc { File.size(path) } }

  let(:config) do
    {
      "Errno::EAGAIN" => {"retries"=>3, "wait"=>0.1},
      "Errno::EIO"    => {"retries"=>1, "wait"=>0.1}
    }
  end

  before do
    allow(described_class).to receive(:config) { config }
  end

  describe "when the block does not raise an exception" do
    it "returns the value of the block" do
      expect(described_class.wrap(&block)).to eq 410226
    end
  end

  describe "when the block raises an exception" do
    describe "and there is a matching error handler" do
      it "retries a certain number of times" do
        allow(File).to receive(:size).with(path).and_raise(Errno::EAGAIN)
        expect(block).to receive(:call).and_call_original.exactly(4).times
        begin
          described_class.wrap(&block)
        rescue Errno::EAGAIN
        end
      end
    end

    describe "and there is no matching error handler" do
      it "raises the exception" do
        allow(File).to receive(:size).with(path).and_raise(Errno::EBADF)
        expect { described_class.wrap(&block) }.to raise_error(Errno::EBADF)
      end
    end
  end

end
