module SidekiqAdhocJob
  class ScheduleAdhocJob

    StringUtil ||= ::SidekiqAdhocJob::Utils::String

    def initialize(job_name, request_params)
      @request_params = request_params.inject({}) do |acc, (k, v)|
        acc[k.to_sym] = v
        acc
      end
      @worker_klass = WorkerClassesLoader.find_worker_klass(job_name)
      parse_params
    end

    def call
      worker_klass.perform_async(*worker_params)
    end

    private

    attr_reader :request_params, :worker_klass, :allowed_params, :worker_params

    def parse_params
      @allowed_params = worker_klass.new.method(:perform).parameters.reject { |type, _| type == :rest }.flat_map(&:last)
      @worker_params = allowed_params.map { |key| StringUtil.parse(request_params[key]) }
      if !!request_params[:rest_args] && !request_params[:rest_args].empty?
        @worker_params += request_params[:rest_args].split(',').map { |arg| StringUtil.parse(arg.strip) }
      end
    end

  end
end
