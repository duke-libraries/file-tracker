require 'rails_helper'

RSpec.describe DuracloudCheck do

  let(:file) { TrackedFile.create!(path: path, md5: md5, sha1: sha1) }
  let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
  let(:md5) { "57a88467c003f53d316a92e8896833b0" }
  let(:path) { File.join(fixture_path, "nypl.jpg") }

  before do
    TrackedDirectory.create!(path: fixture_path, duracloud_space: 'foo')

    Duracloud::Client.configure do |config|
      config.host = "example.com"
      config.user = "testuser"
      config.password = "testpass"
      config.silence_logging!
    end
  end

  describe "when the file has been replicated" do
    describe "and the file is not chunked" do
      before do
        stub_request(:head, "https://example.com/durastore/foo/nypl.jpg")
          .to_return(status: 200, headers: { "Content-MD5" => md5 })
      end
      it "sets the status to REPLICATED" do
        check = described_class.call(file)
        expect(check.status).to eq 0
        check.tracked_file.reload
        expect(check.tracked_file.duracloud_status).to eq 0
        expect(check.tracked_file.duracloud_checked_at).to eq check.checked_at
      end
    end
    describe "and the file is chunked" do
      before do
        stub_request(:head, "https://example.com/durastore/foo/nypl.jpg")
          .to_return(status: 404)
        xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<dur:chunksManifest xmlns:dur="duracloud.org">
  <header schemaVersion="0.2">
    <sourceContent contentId="nypl.jpg">
      <mimetype>application/octet-stream</mimetype>
      <byteSize>4227858432</byteSize>
      <md5>57a88467c003f53d316a92e8896833b0</md5>
    </sourceContent>
  </header>
  <chunks>
    <chunk chunkId="nypl.jpg.dura-chunk-0000" index="0">
      <byteSize>1000000000</byteSize>
      <md5>8a7d5beb2523fb5e4d7c921096be50a9</md5>
    </chunk>
    <chunk chunkId="nypl.jpg.dura-chunk-0001" index="1">
      <byteSize>1000000000</byteSize>
      <md5>e37115d4da0e187130ab645dee4f14ed</md5>
    </chunk>
    <chunk chunkId="nypl.jpg.dura-chunk-0002" index="2">
      <byteSize>1000000000</byteSize>
      <md5>e37115d4da0e187130ab645dee4f14ed</md5>
    </chunk>
    <chunk chunkId="nypl.jpg.dura-chunk-0003" index="3">
      <byteSize>1000000000</byteSize>
      <md5>93e9a4d242a9fb89796b98060094910d</md5>
    </chunk>
    <chunk chunkId="nypl.jpg.dura-chunk-0004" index="4">
      <byteSize>227858432</byteSize>
      <md5>db0124ee56298ff7c7ac17be4ef14871</md5>
    </chunk>
  </chunks>
</dur:chunksManifest>
        XML
        stub_request(:head, "https://example.com/durastore/foo/nypl.jpg.dura-manifest")
        stub_request(:get, "https://example.com/durastore/foo/nypl.jpg.dura-manifest")
          .to_return(status: 200, body: xml)
      end
      it "sets the status to REPLICATED" do
        check = described_class.call(file)
        expect(check.status).to eq 0
        check.tracked_file.reload
        expect(check.tracked_file.duracloud_status).to eq 0
        expect(check.tracked_file.duracloud_checked_at).to eq check.checked_at
      end
    end
  end

  describe "when the md5 does not match" do
    before do
      stub_request(:head, "https://example.com/durastore/foo/nypl.jpg")
        .to_return(status: 200, headers: { "Content-MD5" => "57a88467c003f53d316a92e8896833b1" })
    end
    it "sets the status to CONFLICT" do
      check = described_class.call(file)
      expect(check.status).to eq 1
      check.tracked_file.reload
      expect(check.tracked_file.duracloud_status).to eq 1
      expect(check.tracked_file.duracloud_checked_at).to eq check.checked_at
    end
  end

  describe "when the file has not been replicated" do
    before do
      stub_request(:head, "https://example.com/durastore/foo/nypl.jpg")
        .to_return(status: 404)
      stub_request(:head, "https://example.com/durastore/foo/nypl.jpg.dura-manifest")
        .to_return(status: 404)
    end
    it "sets the status to NOT_REPLICATED" do
      check = described_class.call(file)
      expect(check.status).to eq 2
      check.tracked_file.reload
      expect(check.tracked_file.duracloud_status).to eq 2
      expect(check.tracked_file.duracloud_checked_at).to eq check.checked_at
    end
  end

end
