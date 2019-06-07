require 'sidekiq'
require 'sidekiq/web'

require 'sidekiq_adhoc_job/utils/string'
require 'sidekiq_adhoc_job/utils/class_inspector'
require 'sidekiq_adhoc_job/worker_classes_loader'
require 'sidekiq_adhoc_job/web/job_presenter'
require 'sidekiq_adhoc_job/services/schedule_adhoc_job'
require 'sidekiq_adhoc_job/web'

module SidekiqAdhocJob

  InvalidConfigurationError ||= Class.new(RuntimeError)

  def self.configure
    @_config = Configuration.new
    yield @_config
  end

  def self.config
    @_config
  end

  def self.init
    raise InvalidConfigurationError, 'Must configure before init' unless @_config&.configured?

    SidekiqAdhocJob::WorkerClassesLoader.load(@_config.module_names)

    Sidekiq::Web.register(SidekiqAdhocJob::Web)
    Sidekiq::Web.tabs['adhoc_jobs'] = 'adhoc-jobs'
    Sidekiq::Web.locales << File.expand_path('sidekiq_adhoc_job/web/locales', __dir__)
  end

  class Configuration
    attr_accessor :module_names

    def initialize
      @module_names = []
    end

    def configured?
      !@module_names.empty?
    end
  end

end
