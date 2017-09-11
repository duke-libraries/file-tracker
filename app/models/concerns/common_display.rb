module CommonDisplay

  def display_size
    ActiveSupport::NumberHelper.number_to_human_size(size)
  end

end
