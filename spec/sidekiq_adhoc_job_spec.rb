require 'rack/test'
require_relative '../lib/sidekiq_adhoc_job'
require_relative '../lib/sidekiq_adhoc_job/web/routes/jobs/show'

RSpec.describe SidekiqAdhocJob do

  SPEC_WORKER_PATH = 'spec/support/fixtures/workers/**/*.rb'.freeze

  subject { described_class }

  after do
    SidekiqAdhocJob.instance_eval do
      self.instance_variable_set(:'@_config', nil)
    end
  end

  describe '.configure' do
    it 'yields configuration object' do
      expect { |blk| subject.configure(&blk) }.to yield_with_args(instance_of(SidekiqAdhocJob::Configuration))
    end
  end

  describe '.config' do
    it 'returns configuration object' do
      subject.configure { |config| config.module_names = [:'SidekiqAdhocJob::Test'] }
      expect(subject.config).to be_an_instance_of(SidekiqAdhocJob::Configuration)
    end
  end

  describe '.init' do
    context 'configure first' do
      it 'loads worker files and adds web extension' do
        subject.configure do |config|
          config.module_names = [:'SidekiqAdhocJob::Test', :'SidekiqAdhocJob::OtherTest', :'SidekiqAdhocJob::Test::Worker']
        end

        expect(Sidekiq::Web).to receive(:register).with(SidekiqAdhocJob::Web)

        subject.init

        expect(SidekiqAdhocJob::WorkerClassesLoader.worker_klasses.values).to match_array(
          [
            SidekiqAdhocJob::OtherTest::DifferentNamespaceWorker,
            SidekiqAdhocJob::Test::DummyNoArgWorker,
            SidekiqAdhocJob::Test::DummyRestArgsWorker,
            SidekiqAdhocJob::Test::DummyWorker,
            SidekiqAdhocJob::Test::NamespacedWorker,
            SidekiqAdhocJob::Test::NestedPrependedWorker,
            SidekiqAdhocJob::Test::PrependedAndInheritedWorker,
            SidekiqAdhocJob::Test::PrependedWorker,
            SidekiqAdhocJob::Test::Worker::NestedNamespacedWorker,
            SidekiqAdhocJob::Test::SampleCSVWorker,
            SidekiqAdhocJob::Test::NonExplicit
          ]
        )
      end

      it 'formats module names properly' do
        subject.configure do |config|
          config.module_names = [:'SidekiqAdhocJob::Test', :'SidekiqAdhocJob::OtherTest', :'SidekiqAdhocJob::Test::Worker']
        end

        expect(subject.config.module_names).to eq [
          'SidekiqAdhocJob::Test',
          'SidekiqAdhocJob::OtherTest',
          'SidekiqAdhocJob::Test::Worker'
        ]
      end
    end

    context 'different strategy: active_job' do
      it 'loads worker files and adds web extension' do
        subject.configure do |config|
          config.module_names = [:'SidekiqAdhocJob::ActiveJobTest']
          config.strategy_name = :active_job
        end

        expect(Sidekiq::Web).to receive(:register).with(SidekiqAdhocJob::Web)

        subject.init

        expect(SidekiqAdhocJob::WorkerClassesLoader.worker_klasses.values).to match_array(
          [
            SidekiqAdhocJob::ActiveJobTest::DummyActiveJob
          ]
        )
      end
    end

    context 'different strategy: rails_application_job' do
      it 'loads worker files and adds web extension' do
        subject.configure do |config|
          config.module_names = [:'SidekiqAdhocJob::RailsApplicationJobTest']
          config.strategy_name = :rails_application_job
        end

        expect(Sidekiq::Web).to receive(:register).with(SidekiqAdhocJob::Web)

        subject.init

        expect(SidekiqAdhocJob::WorkerClassesLoader.worker_klasses.values).to match_array(
          [
            SidekiqAdhocJob::RailsApplicationJobTest::DummyApplicationJob
          ]
        )
      end
    end

    context 'allow_override_params: false' do
      include Rack::Test::Methods
      include_context 'request setup'

      before do
        subject.configure do |config|
          config.allow_override_params = false
        end

        subject.init
      end

      it 'does not render override params form'  do
        get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker'

        expect(last_response.status).to eq 200

        response_body = compact_html(last_response.body)

        expect(response_body).not_to include(compact_html(
          <<~HTML
          <p>Let me override all the arguments, I know what I'm doing.</p>
          HTML
        ))
      end
    end

    context 'allow_override_params: true' do
      include Rack::Test::Methods
      include_context 'request setup'

      before do
        subject.configure do |config|
          config.allow_override_params = true
        end

        subject.init
      end

      it 'renders override params form'  do
        get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker'

        expect(last_response.status).to eq 200

        response_body = compact_html(last_response.body)

        expect(response_body).to include(compact_html(
          <<~HTML
          <p>Let me override all the arguments, I know what I'm doing.</p>
          HTML
        ))
      end
    end
  end
end
