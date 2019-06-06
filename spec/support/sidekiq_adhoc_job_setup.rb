require_relative '../../lib/sidekiq_adhoc_job'

RSpec.shared_context 'SidekiqAdhocJob setup' do
  before do
    SidekiqAdhocJob.configure do |config|
      config.module_names = [:'SidekiqAdhocJob::Test', :'SidekiqAdhocJob::Test::Worker']
    end
    SidekiqAdhocJob.init
  end
end
