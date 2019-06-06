require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class NamespacedWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform
      end

    end
  end
end
