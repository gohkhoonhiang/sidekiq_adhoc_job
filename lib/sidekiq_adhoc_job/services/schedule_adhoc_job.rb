module SidekiqAdhocJob
  class ScheduleAdhocJob

    StringUtil ||= ::SidekiqAdhocJob::Utils::String

    def initialize(job_name, request_params)
      @request_params = request_params.inject({}) do |acc, (k, v)|
        acc[k.to_sym] = v
        acc
      end
      @worker_klass = WorkerClassesLoader.find_worker_klass(job_name)
      @worker_klass_inspector = Utils::ClassInspector.new(worker_klass)
      @allowed_params = worker_klass_inspector.required_parameters(:perform) + worker_klass_inspector.optional_parameters(:perform)

      parse_params
    end

    def call
      SidekiqAdhocJob.config.strategy.perform_async(worker_klass, *worker_params)
    end

    private

    attr_reader :request_params, :worker_klass, :worker_klass_inspector,
                :allowed_params, :worker_params

    def parse_params
      @worker_params = allowed_params.map { |key| StringUtil.parse(request_params[key], symbolize: true) }
      if !!request_params[:rest_args] && !request_params[:rest_args].empty?
        @worker_params << StringUtil.parse_json(request_params[:rest_args].strip, symbolize: true)
      end
    end

  end
end
