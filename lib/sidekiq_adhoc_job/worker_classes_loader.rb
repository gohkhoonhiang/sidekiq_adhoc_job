module SidekiqAdhocJob
  class WorkerClassesLoader
    @_worker_klasses = {}

    module ClassMethods
      def load(module_parent_names)
        ObjectSpace.each_object(Class).each do |klass|
          if worker_class?(klass) && match_module_parent_name?(klass.name, allowlist: module_parent_names)
            @_worker_klasses[worker_path_name(klass.name)] = klass
          end
        end
      end

      def worker_klasses
        @_worker_klasses
      end

      def find_worker_klass(path_name)
        @_worker_klasses[path_name]
      end

      private

        def worker_class?(klass)
          klass.included_modules.include?(Sidekiq::Worker)
        end

        def match_module_parent_name?(class_name, allowlist:)
          allowed_parent_names = allowlist.map(&:to_s)

          return true if allowed_parent_names.empty? || allowed_parent_names.include?("Module")

          allowed_parent_names.any? { |prefix| class_name.start_with?(prefix) }
        end

        def worker_path_name(worker_name)
          Utils::String.underscore(worker_name).gsub('/', '_')
        end
    end
    extend ClassMethods
  end
end
