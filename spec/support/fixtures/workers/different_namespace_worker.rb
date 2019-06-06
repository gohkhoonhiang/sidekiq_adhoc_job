require 'sidekiq'

module SidekiqAdhocJob
  module OtherTest
    class DifferentNamespaceWorker
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform
      end

    end
  end
end
