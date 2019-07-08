module SidekiqAdhocJob
  class WorkerClassesLoader

    StringUtil ||= Utils::String

    @_worker_klasses = {}

    def self.load(module_names)
      module_consts = module_names.map { |name| StringUtil.constantize(name.to_s) }
      module_consts.each do |module_const|
        module_const.constants.each do |sub_module_const_sym|
          load_workers(module_const, sub_module_const_sym, @_worker_klasses)
        end
      end
    end

    def self.worker_klasses
      @_worker_klasses
    end

    def self.find_worker_klass(path_name)
      @_worker_klasses[path_name]
    end

    def self.load_workers(parent_module_const, module_sym, workers)
      qualified_name = module_sym.to_s

      module_const = begin
                       StringUtil.constantize(qualified_name)
                     rescue NameError => _e
                       qualified_name = [parent_module_const, module_sym].compact.join('::')
                       begin
                         StringUtil.constantize(qualified_name)
                       rescue NameError => _e
                         nil
                       end
                     end
      return unless module_const && module_const.is_a?(Class)

      if module_const.include?(Sidekiq::Worker)
        path_name = StringUtil.underscore(qualified_name).gsub('/', '_')
        workers[path_name] = module_const
        return
      end
    end

  end
end
