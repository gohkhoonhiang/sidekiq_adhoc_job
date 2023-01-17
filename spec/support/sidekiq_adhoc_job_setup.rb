require_relative '../../lib/sidekiq_adhoc_job'

RSpec.shared_context 'SidekiqAdhocJob setup' do
  let(:init_first?) { true }

  let(:require_confirm_worker_names) do
    %w[
      SidekiqAdhocJob::Test::NamespacedWorker
      SidekiqAdhocJob::Test::SampleCSVWorker
      SidekiqAdhocJob::Test::DummyWorker
    ]
  end
  let(:module_names) { %i[SidekiqAdhocJob::Test SidekiqAdhocJob::Test::Worker] }
  let(:strategy_name) { :default }

  before do
    SidekiqAdhocJob.configure do |config|
      config.require_confirm_worker_names = require_confirm_worker_names
      config.module_names = module_names
      config.strategy_name = strategy_name
    end
    SidekiqAdhocJob.init if init_first?
  end

  after do
    SidekiqAdhocJob.instance_eval do
      instance_variable_set(:'@_config', nil)
    end
  end
end
