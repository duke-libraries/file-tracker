class FixitySummary

  def self.call
    %w( ok modified missing error ).each_with_object({}) do |status, memo|
      memo[status] = TrackedFile.send(status).count
    end
  end

end
