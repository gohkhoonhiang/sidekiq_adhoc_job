require 'sidekiq'

module SidekiqAdhocJob
  module Test
    module LogArgs
      def perform(*args)
        puts args
        super(*args)
      end
    end

    module ParentArgs
      def perform(*args)
      end
    end

    class PrependedAndInheritedWorker
      prepend LogArgs
      include ParentArgs
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform(id, overwrite, retry_job = true, retries = 5, interval = 1.5)
      end

    end
  end
end
