require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class SampleCSVWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform
      end

    end
  end
end
