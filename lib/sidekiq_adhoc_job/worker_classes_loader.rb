module SidekiqAdhocJob
  class WorkerClassesLoader
    @_worker_klasses = {}

    def self.load(module_names, strategy:, load_paths:)
      require_files(load_paths)
      strategy.load
      @_worker_klasses = strategy.worker_klasses
    end

    def self.worker_klasses
      @_worker_klasses
    end

    def self.find_worker_klass(path_name)
      @_worker_klasses[path_name]
    end

    def self.require_files(load_paths)
      Dir[File.join("", load_paths)].each { |path| require path } unless load_paths.empty?
    end
  end
end
