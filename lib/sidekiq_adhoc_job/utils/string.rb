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

      # Return a CamelCase version of the string
      # If the given string is a file name, it will convert each file directory into a CamelCase namespace
      #
      # @see https://github.com/hanami/utils/blob/92ef4464f7ae3e5acba4b8fadc1c8225a81b9b76/lib/hanami/utils/string.rb#L223
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'sidekiq_adhoc_job/utils/string'
      #
      #   SidekiqAdhocJob::Utils::String.classify('sidekiq_adhoc_job') # => 'SidekiqAdhocJob'
      #   SidekiqAdhocJob::Utils::String.classify('sidekiq_adhoc_job/utils/string') # => 'SidekiqAdhocJob::Utils::String'
      def self.classify(input)
        string = ::String.new(input.to_s)
        words = underscore(string).split(CLASSIFY_WORD_SEPARATOR).map!(&:capitalize)
        delimiters = underscore(string).scan(CLASSIFY_WORD_SEPARATOR)

        delimiters.map! do |delimiter|
          delimiter == CLASSIFY_SEPARATOR ? EMPTY_STRING : NAMESPACE_SEPARATOR
        end

        words.zip(delimiters).join
      end

      # Return a downcased and underscore separated version of the string
      # If the given string is a namespaced class name, it will convert the namespace separator :: into a file path separator /
      #
      # @see https://github.com/hanami/utils/blob/92ef4464f7ae3e5acba4b8fadc1c8225a81b9b76/lib/hanami/utils/string.rb#L250
      #
      # @param input [::String] the input
      #
      # @return [::String] the transformed string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'sidekiq_adhoc_job/utils/string'
      #
      #   SidekiqAdhocJob::Utils::String.underscore('SidekiqAdhocJob') # => 'sidekiq_adhoc_job'
      #   SidekiqAdhocJob::Utils::String.underscore('SidekiqAdhocJob::Utils::String') # => 'sidekiq_adhoc_job/utils/string'
      def self.underscore(input)
        string = ::String.new(input.to_s)
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
        elsif input == 'nil'
          nil
        elsif (i = parse_integer(input))
          i
        elsif (f = parse_float(input))
          f
        elsif (j = parse_json(input))
          j
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

      def self.parse_json(input)
        JSON.parse(input)
      rescue JSON::ParserError => _e
        nil
      end

    end
  end
end
