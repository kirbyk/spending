class String
  def titleize(options = {})
    exclusions = options[:exclude]

    return ActiveSupport::Inflector.titleize(self) unless exclusions.present?
    self.underscore.humanize.gsub(/\b(?<!['’`])(?!(#{exclusions.join('|')})\b)[a-z]/) { $&.capitalize }
  end
end
