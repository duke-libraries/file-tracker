require 'rails_helper'
require 'tempfile'

RSpec.describe TrackedFile do

  before do
    @file = Tempfile.create("tracked-file-")
    @path = @file.path
  end

  after do
    if File.exist?(@path)
      @file.close unless @file.closed?
      File.unlink(@path)
    end
  end

  subject { described_class.new(path: @path) }

end
