require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class DummyWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform(id, overwrite, retry_job = true, retries = 5, interval = 1.5)
      end

    end
  end
end
