# frozen_string_literal: true

module RubySunrise
  # Gem identity information.
  module Identity
    def self.name
      "ruby_sunrise"
    end

    def self.label
      "Ruby Sunrise"
    end

    def self.version
      "0.3.1"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
