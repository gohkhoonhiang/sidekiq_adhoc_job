module SidekiqAdhocJob
  module Web
    VIEW_PATH  ||= File.expand_path('web/templates', __dir__)
    ROUTE_PATH ||= File.expand_path('web/routes', __dir__)

    StringUtil ||= ::SidekiqAdhocJob::Utils::String

    def self.registered(app)
      Dir[File.join(ROUTE_PATH, '**/*.rb')].each do |file_name|
        require_relative file_name

        relative_path = Pathname.new(file_name).relative_path_from(ROUTE_PATH)
        module_name = StringUtil.classify(File.dirname(relative_path))
        klass_name = StringUtil.classify(File.basename(relative_path, '.rb'))
        namespaced_klass_name = StringUtil.constantize("SidekiqAdhocJob::Web::#{module_name}::#{klass_name}")
        namespaced_klass_name.register(app)
      end
    end

  end
end

Sidekiq::Web.register(SidekiqAdhocJob::Web)
Sidekiq::Web.tabs['adhoc_jobs'] = 'adhoc-jobs'
Sidekiq::Web.locales << File.expand_path('web/locales', __dir__)

SidekiqAdhocJob::WorkerFilesLoader.load
