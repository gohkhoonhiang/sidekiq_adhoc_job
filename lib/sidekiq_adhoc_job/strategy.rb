module SidekiqAdhocJob
  module Strategy
    def self.included(base)
      SidekiqAdhocJob.strategies << base

      base.extend ClassMethods
      base.class_eval do
      end
    end

    attr_reader :module_names, :worker_klasses

    StringUtil ||= SidekiqAdhocJob::Utils::String

    def initialize(module_names)
      @module_names = module_names
      @worker_klasses = {}
    end

    def load
      ObjectSpace.each_object(Class).each do |klass|
        next unless klass

        if worker_class?(klass) && allowed_namespace?(klass.name, allowlist: module_names)
          @worker_klasses[worker_path_name(klass.name)] = klass
        end
      end
    end

    def allowed_namespace?(class_name, allowlist:)
      return true if allowlist.empty? || allowlist.include?('Module') # allow any namespace

      allowlist.any? { |prefix| class_name.start_with?(prefix) }
    end

    def worker_path_name(worker_name)
      Utils::String.underscore(worker_name).gsub('/', '_')
    end

    module ClassMethods
    end
  end
end
