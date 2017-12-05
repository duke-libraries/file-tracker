require 'pathname'

module HasPathname
  def pathname
    @pathname ||= Pathname.new(path)
  end
end
