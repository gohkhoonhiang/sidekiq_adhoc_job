require 'sidekiq'

module SidekiqAdhocJob
  module Test::Worker
    class NestedNamespacedWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform
      end

    end
  end
end
