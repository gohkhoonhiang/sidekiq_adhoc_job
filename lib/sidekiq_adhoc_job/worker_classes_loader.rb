module SidekiqAdhocJob
  class WorkerClassesLoader

    VALID_QUALIFIED_CLASS_NAME ||= /\A(([A-Z]{1}[a-z]+)(::)*)+\z/
    VALID_WORKER_CLASS_NAME ||= /^.+\b[^(::)]+Worker$/

    StringUtil ||= Utils::String

    @_worker_klasses = {}

    def self.load(module_names)
      module_names.each do |module_name|
        load_workers(nil, module_name, @_worker_klasses)
      end
    end

    def self.worker_klasses
      @_worker_klasses
    end

    def self.find_worker_klass(path_name)
      @_worker_klasses[path_name]
    end

    def self.load_workers(parent_module_name, module_name, workers)
      qualified_name = [parent_module_name, module_name].compact.join('::')
      return unless VALID_QUALIFIED_CLASS_NAME.match?(qualified_name)

      module_const = StringUtil.constantize(qualified_name)
      return unless module_const

      if VALID_WORKER_CLASS_NAME.match?(qualified_name)
        path_name = StringUtil.underscore(qualified_name).gsub('/', '_')
        workers[path_name] = module_const
        return
      end

      module_const.constants.each do |module_sub_const|
        load_workers(qualified_name, module_sub_const.to_s, workers)
      end
    end

  end
end
