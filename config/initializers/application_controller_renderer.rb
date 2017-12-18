ActionController::Renderers.add :csv do |obj, opts|
  options = opts.dup
  filename = options.delete(:filename) || 'data'
  csv = obj.respond_to?(:to_csv) ? obj.to_csv(options) : obj.to_s
  send_data csv,
            type: Mime[:csv],
            disposition: "attachment; filename=#{filename}.csv"
end
