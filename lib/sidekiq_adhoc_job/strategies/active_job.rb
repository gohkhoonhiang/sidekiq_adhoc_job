module SidekiqAdhocJob
  module Strategies
    class ActiveJob
      include SidekiqAdhocJob::Strategy

      def worker_class?(klass)
        klass.superclass&.name == 'ActiveJob::Base'
      end

      def get_queue_name(klass_name)
        klass_name.queue_name
      end

      def perform_async(klass, *params)
        klass.perform_later(*params)
      end
    end
  end
end
