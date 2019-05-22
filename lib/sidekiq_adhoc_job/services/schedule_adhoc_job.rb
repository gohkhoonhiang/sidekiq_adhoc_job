module SidekiqAdhocJob
  class ScheduleAdhocJob

    StringUtil ||= ::SidekiqAdhocJob::Utils::String

    def initialize(job_name, request_params)
      @request_params = request_params.inject({}) do |acc, (k, v)|
        acc[k.to_sym] = v
        acc
      end
      @worker_klass = StringUtil.classify(job_name).constantize
      parse_params
    end

    def call
      worker_klass.perform_async(*worker_params)
    end

    private

    attr_reader :request_params, :worker_klass, :allowed_params, :worker_params

    def parse_params
      @allowed_params = worker_klass.new.method(:perform).parameters.flat_map(&:last)
      @worker_params = allowed_params.map { |key| StringUtil.parse(request_params[key]) }
    end

  end
end
