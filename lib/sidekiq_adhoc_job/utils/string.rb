# References: https://github.com/hanami/utils/blob/master/lib/hanami/utils/string.rb
module SidekiqAdhocJob
  module Utils
    class String

      EMPTY_STRING               ||= ''.freeze
      CLASSIFY_SEPARATOR         ||= '_'.freeze
      NAMESPACE_SEPARATOR        ||= '::'.freeze
      UNDERSCORE_SEPARATOR       ||= '/'.freeze
      UNDERSCORE_DIVISION_TARGET ||= '\1_\2'.freeze
      DASHERIZE_SEPARATOR        ||= '-'.freeze
      CLASSIFY_WORD_SEPARATOR    ||= /#{CLASSIFY_SEPARATOR}|#{NAMESPACE_SEPARATOR}|#{UNDERSCORE_SEPARATOR}|#{DASHERIZE_SEPARATOR}/.freeze

      def self.classify(input)
        string = ::String.new(input.to_s)
        words = underscore(string).split(CLASSIFY_WORD_SEPARATOR).map!(&:capitalize)
        delimiters = underscore(string).scan(CLASSIFY_WORD_SEPARATOR)

        delimiters.map! do |delimiter|
          delimiter == CLASSIFY_SEPARATOR ? EMPTY_STRING : NAMESPACE_SEPARATOR
        end

        words.zip(delimiters).join
      end

      def self.underscore(input)
        string = ::String.new(input.to_s)
        string.gsub!(NAMESPACE_SEPARATOR, UNDERSCORE_SEPARATOR)
        string.gsub!(NAMESPACE_SEPARATOR, UNDERSCORE_SEPARATOR)
        string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, UNDERSCORE_DIVISION_TARGET)
        string.gsub!(/([a-z\d])([A-Z])/, UNDERSCORE_DIVISION_TARGET)
        string.gsub!(/[[:space:]]|\-/, UNDERSCORE_DIVISION_TARGET)
        string.downcase
      end

      def self.constantize(input)
        names = input.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end

      def self.parse(input)
        return unless input

        if input == 'true'
          true
        elsif input == 'false'
          false
        elsif (i = parse_integer(input))
          i
        elsif (f = parse_float(input))
          f
        else
          input
        end
      end

      def self.parse_integer(input)
        Integer(input)
      rescue ArgumentError => _e
        nil
      end

      def self.parse_float(input)
        Float(input)
      rescue ArgumentError => _e
        nil
      end

    end
  end
end
