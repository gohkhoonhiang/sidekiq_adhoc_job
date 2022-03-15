require_relative '../../lib/sidekiq_adhoc_job'

RSpec.shared_context 'SidekiqAdhocJob setup' do
  before do
    SidekiqAdhocJob.configure do |config|
      config.module_names = [:'SidekiqAdhocJob::Test', :'SidekiqAdhocJob::Test::Worker']
      config.require_confirm_worker_names = 
        %w[
          SidekiqAdhocJob::Test::NamespacedWorker
          SidekiqAdhocJob::Test::SampleCSVWorker
        ]
    end
    SidekiqAdhocJob.init
  end
end
