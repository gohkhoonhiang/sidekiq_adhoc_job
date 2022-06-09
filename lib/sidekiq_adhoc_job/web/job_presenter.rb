# References: https://github.com/moove-it/sidekiq-scheduler/blob/master/lib/sidekiq-scheduler/job_presenter.rb
module SidekiqAdhocJob
  module Web
    class JobPresenter
      include Sidekiq::WebHelpers

      attr_reader :name,
                  :path_name,
                  :queue,
                  :required_args,
                  :optional_args,
                  :required_kw_args,
                  :optional_kw_args,
                  :has_rest_args,
                  :require_confirm,
                  :confirm_prompt_message

      StringUtil ||= ::SidekiqAdhocJob::Utils::String

      # args: { req: [], opt: [] }
      def initialize(name, path_name, queue, args, require_confirm)
        @name = name
        @path_name = path_name
        @queue = queue
        @required_args = args[:req] || []
        @optional_args = args[:opt] || []
        @required_kw_args = args[:keyreq] || []
        @optional_kw_args = args[:key] || []
        @has_rest_args = !!args[:rest]
        @require_confirm = require_confirm
        @confirm_prompt_message = SidekiqAdhocJob.config.require_confirm_prompt_message
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
        queue = SidekiqAdhocJob.config.strategy.get_queue_name(klass_name)
        class_inspector = SidekiqAdhocJob::Utils::ClassInspector.new(klass_name)
        args = class_inspector.parameters(:perform)
        require_confirm = SidekiqAdhocJob.config.require_confirmation?(klass_name.to_s)
        new(klass_name, path_name, queue, args, require_confirm)
      end

      def no_arguments?
        required_args.empty? && optional_args.empty? && required_kw_args.empty? && optional_kw_args.empty? && !has_rest_args
      end

    end
  end
end
