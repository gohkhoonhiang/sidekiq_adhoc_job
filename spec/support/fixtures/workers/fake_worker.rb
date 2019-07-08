require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class FakeWorker

      def perform
      end

    end
  end
end
