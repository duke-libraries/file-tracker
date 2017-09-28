require 'listen'

class ListenerFactory
  def self.call(*paths)
    Listen.to(*paths) do |modified, added, removed|
      ActiveSupport::Notifications.instrument("changes.file_tracker",
                                              paths: paths,
                                              modified: modified,
                                              added: added,
                                              removed: removed)
    end
  end
end
