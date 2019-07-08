require 'sidekiq'

module SidekiqAdhocJob
  module Test
    class NonExplicit
      include Sidekiq::Worker

      sidekiq_options queue: 'dummy'

      def perform
      end

    end
  end
end
