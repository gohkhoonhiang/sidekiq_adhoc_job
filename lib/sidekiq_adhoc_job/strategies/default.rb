module SidekiqAdhocJob
  module Strategies
    class Default
      include SidekiqAdhocJob::Strategy

      def worker_class?(klass)
        klass.included_modules.include?(Sidekiq::Worker)
      end

      def get_queue_name(klass_name)
        klass_name.sidekiq_options['queue']
      end

      def perform_async(klass, *params, **kw_params)
        klass.perform_async(*params, **kw_params)
      end
    end
  end
end
