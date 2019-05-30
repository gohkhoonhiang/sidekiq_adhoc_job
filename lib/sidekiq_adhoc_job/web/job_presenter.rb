# References: https://github.com/moove-it/sidekiq-scheduler/blob/master/lib/sidekiq-scheduler/job_presenter.rb
module SidekiqAdhocJob
  module Web
    class JobPresenter
      include Sidekiq::WebHelpers

      attr_reader :name, :path_name, :queue, :required_args, :optional_args, :args

      StringUtil ||= ::SidekiqAdhocJob::Utils::String

      # args: { req: [], opt: [] }
      def initialize(name, queue, args)
        @name = name
        @queue = queue
        @path_name = StringUtil.underscore(name.to_s.split('::').last)
        @required_args = args[:req] || []
        @optional_args = args[:opt] || []
        @args = @required_args + @optional_args
      end

      # Builds the presenter instances for the schedule hash
      #
      # @param
      # @return [Array<JobPresenter>] an array with the instances of presenters
      def self.build_collection
        WorkerFilesLoader.worker_files.map do |worker_file|
          klass_name = read_klass_name_from_file(worker_file)
          convert_klass_name_to_presenter(klass_name)
        end
      end

      def self.find(name)
        file_path = WorkerFilesLoader.find_file(name)

        return unless file_path

        return unless File.exist?(file_path)

        klass_name = read_klass_name_from_file(file_path)

        convert_klass_name_to_presenter(klass_name)
      end

      def self.convert_klass_name_to_presenter(file_name)
        klass_name = StringUtil.constantize(StringUtil.classify(file_name))
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
        new(klass_name, queue, args)
      end

      def self.read_klass_name_from_file(file_path)
        file = File.read(file_path)
        file
          .split("\n")
          .select { |line| line =~ /(module)|(class)/ }
          .map { |str| str.gsub(/module/,'').gsub(/class/,'').strip }
          .join("::")
      end

    end
  end
end
