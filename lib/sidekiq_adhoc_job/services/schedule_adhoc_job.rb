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

      parse_params
    end

    def call
      SidekiqAdhocJob.config.strategy.perform_async(worker_klass, *worker_positional_params, **worker_keyword_params)
    end

    private

    attr_reader :request_params, :worker_klass, :worker_klass_inspector, :worker_positional_params, :worker_keyword_params

    def parse_params
      @worker_positional_params = positional_params
        .reject { |key| request_params[key].empty? }
        .map { |key| StringUtil.parse(request_params[key], symbolize: true) }
      @worker_keyword_params = keyword_params
        .each_with_object({}) { |key, obj| obj[key.to_sym] = request_params[key] }
        .compact
      if !!request_params[:rest_args] && !request_params[:rest_args].empty?
        @worker_positional_params << StringUtil.parse_json(request_params[:rest_args].strip, symbolize: true)
      end
    end

    def allowed_params
      worker_positional_params + worker_keyword_params
    end

    def positional_params
      worker_klass_inspector.required_parameters(:perform) +
        worker_klass_inspector.optional_parameters(:perform)
    end

    def keyword_params
      worker_klass_inspector.required_kw_parameters(:perform) +
        worker_klass_inspector.optional_kw_parameters(:perform)
    end

  end
end
