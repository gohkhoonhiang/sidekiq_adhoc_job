require 'sidekiq'
require 'sidekiq_adhoc_job/utils/string'

module SidekiqAdhocJob
  module Test
    StringUtil ||= SidekiqAdhocJob::Utils::String

    module LogArgs
      def perform(*args)
        puts args
        super(*args)
      end
    end

    module SanitizeArgs
      def perform(*args)
        sanitized_args = sanitize(args)
        super(*sanitized_args)
      end

      private

      def sanitized_args(*args)
        args.map do |arg|
          StringUtil.parse(arg.strip)
        end
      end
    end

    class NestedPrependedWorker
      prepend SanitizeArgs
      prepend LogArgs
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform(id, overwrite, retry_job = true, retries = 5, interval = 1.5)
      end

    end
  end
end
