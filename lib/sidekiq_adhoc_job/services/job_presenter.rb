module SidekiqAdhocJob
  class JobPresenter
    include Sidekiq::WebHelpers

    attr_reader :name, :path_name, :queue, :required_args, :optional_args, :args

    StringUtil ||= ::SidekiqAdhocJob::Utils::String

    # args: { req: [], opt: [] }
    def initialize(name, queue, args)
      @name = name
      @queue = queue
      @path_name = StringUtil.underscore(name)
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
        file_name = File.basename(worker_file, '.rb')
        convert_file_name_to_presenter(file_name)
      end
    end

    def self.find(name)
      file_name = WorkerFilesLoader.find_file(name)

      return unless file_name

      return unless File.exist?(file_name)

      convert_file_name_to_presenter(name)
    end

    def self.convert_file_name_to_presenter(file_name)
      klass_name = StringUtil.classify(file_name).constantize
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

  end
end
