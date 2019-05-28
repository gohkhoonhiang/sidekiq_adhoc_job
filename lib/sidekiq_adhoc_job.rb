require 'sidekiq'
require 'sidekiq/web'

require 'sidekiq_adhoc_job/utils/string'
require 'sidekiq_adhoc_job/worker_files_loader'
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

    SidekiqAdhocJob::WorkerFilesLoader.load(@_config.worker_path_pattern)

    Sidekiq::Web.register(SidekiqAdhocJob::Web)
    Sidekiq::Web.tabs['adhoc_jobs'] = 'adhoc-jobs'
    Sidekiq::Web.locales << File.expand_path('sidekiq_adhoc_job/web/locales', __dir__)
  end

  class Configuration
    attr_accessor :worker_path_pattern, :ignore_spec

    def initialize
      @ignore_spec = true
    end

    def configured?
      !@worker_path_pattern.nil?
    end
  end

end
