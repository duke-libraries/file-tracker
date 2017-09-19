class FixityJob < ApplicationJob

  def base_queue_name
    self.class.name.sub(/Job\z/, "").underscore
  end

  queue_as do
    tracked_file = self.arguments.first
    if large_file?(tracked_file.path)
      base_queue_name + "_large"
    else
      base_queue_name
    end
  end

end
