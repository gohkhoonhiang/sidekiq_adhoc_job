require 'sidekiq'
require 'sidekiq/web'

require 'sidekiq_adhoc_job/utils/string'
require 'sidekiq_adhoc_job/worker_files_loader'
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
    raise InvalidConfigurationError, 'Must configure before init' unless @_config

    SidekiqAdhocJob::WorkerFilesLoader.load(@_config.worker_path_pattern)

    Sidekiq::Web.register(SidekiqAdhocJob::Web)
    Sidekiq::Web.tabs['adhoc_jobs'] = 'adhoc-jobs'
    Sidekiq::Web.locales << File.expand_path('sidekiq_adhoc_job/web/locales', __dir__)
  end

  class Configuration
    attr_accessor :worker_path_pattern, :ignore_spec

    def initialize
      @worker_path_pattern = '**/workers/**/*.rb'
      @ignore_spec = true
    end
  end

end
