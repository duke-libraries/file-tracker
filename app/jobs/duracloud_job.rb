require 'duracloud'

class DuracloudJob < ApplicationJob

  self.queue = :duracloud

end
