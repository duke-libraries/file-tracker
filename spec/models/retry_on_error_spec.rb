require 'rails_helper'

RSpec.describe RetryOnError do

  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:block) { proc { File.size(path) } }
  let(:exceptions) { [ Errno::EAGAIN, Errno::EIO ] }
  subject { described_class.new(exceptions: exceptions, wait: 0.1) }

  describe "when the block does not raise an exception" do
    it "returns the value of the block" do
      expect(subject.wrap(&block)).to eq 410226
    end
  end

  describe "when the block raises an exception" do
    describe "and there is a matching error handler" do
      it "retries a certain number of times" do
        allow(File).to receive(:size).with(path).and_raise(Errno::EAGAIN)
        expect(block).to receive(:call).and_call_original.exactly(4).times
        begin
          subject.wrap(&block)
        rescue Errno::EAGAIN
        end
      end
    end

    describe "and the exception is not retriable" do
      it "raises the exception" do
        allow(File).to receive(:size).with(path).and_raise(Errno::EBADF)
        expect { subject.wrap(&block) }.to raise_error(Errno::EBADF)
      end
    end
  end

end
