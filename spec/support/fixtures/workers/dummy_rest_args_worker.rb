require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class DummyRestArgsWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform(id, *args)
      end

    end
  end
end
