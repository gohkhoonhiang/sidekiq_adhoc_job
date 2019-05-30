# References: https://github.com/moove-it/sidekiq-scheduler/blob/master/lib/sidekiq-scheduler/job_presenter.rb
module SidekiqAdhocJob
  module Web
    class JobPresenter
      include Sidekiq::WebHelpers

      attr_reader :name, :path_name, :queue, :required_args, :optional_args, :args

      StringUtil ||= ::SidekiqAdhocJob::Utils::String

      # args: { req: [], opt: [] }
      def initialize(name, path_name, queue, args)
        @name = name
        @path_name = path_name
        @queue = queue
        @required_args = args[:req] || []
        @optional_args = args[:opt] || []
        @args = @required_args + @optional_args
      end

      # Builds the presenter instances for the schedule hash
      #
      # @param
      # @return [Array<JobPresenter>] an array with the instances of presenters
      def self.build_collection
        WorkerClassesLoader.worker_klasses.map do |path_name, worker_klass|
          convert_klass_name_to_presenter(path_name, worker_klass)
        end
      end

      def self.find(path_name)
        klass_name = WorkerClassesLoader.find_worker_klass(path_name)

        return unless klass_name

        convert_klass_name_to_presenter(path_name, klass_name)
      end

      def self.convert_klass_name_to_presenter(path_name, klass_name)
        klass_obj = klass_name.new
        queue = klass_name.sidekiq_options['queue']
        args = klass_obj
               .method(:perform)
               .parameters
               .group_by { |type, _| type }
               .inject({}) do |acc, (type, params)|
                 acc[type] = params.map(&:last)
                 acc
               end
        new(klass_name, path_name, queue, args)
      end

    end
  end
end
