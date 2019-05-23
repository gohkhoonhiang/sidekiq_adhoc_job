require_relative '../../lib/sidekiq_adhoc_job'

RSpec.shared_context 'SidekiqAdhocJob setup' do
  before do
    SidekiqAdhocJob.configure do |config|
      config.worker_path_pattern = 'spec/support/fixtures/workers/**/*.rb'
      config.ignore_spec = false
    end
    SidekiqAdhocJob.init
  end
end
