module SidekiqAdhocJob
  class WorkerClassesLoader
    @_worker_klasses = {}

    def self.load(module_names)
      ObjectSpace.each_object(Class).each do |klass|
        if worker_class?(klass) && allowed_namespace?(klass.name, allowlist: module_names)
          @_worker_klasses[worker_path_name(klass.name)] = klass
        end
      end
    end

    def self.worker_klasses
      @_worker_klasses
    end

    def self.find_worker_klass(path_name)
      @_worker_klasses[path_name]
    end

    def self.worker_class?(klass)
      klass.included_modules.include?(Sidekiq::Worker)
    end
    private_class_method :worker_class?

    def self.allowed_namespace?(class_name, allowlist:)
      allowed_namespaces = allowlist.map(&:to_s)

      # allow any workers
      return true if allowed_namespaces.empty? || allowed_namespaces.include?('Module')

      allowed_namespaces.any? { |prefix| class_name.start_with?(prefix) }
    end
    private_class_method :allowed_namespace?

    def self.worker_path_name(worker_name)
      Utils::String.underscore(worker_name).gsub('/', '_')
    end
    private_class_method :worker_path_name
  end
end
