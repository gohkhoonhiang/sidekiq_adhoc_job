require_relative '../lib/sidekiq_adhoc_job'

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

    context 'when require_confirm_prompt_message is not string' do
      subject do
        described_class.configure { |config| config.require_confirm_prompt_message = {'not' => %w[a string] } }
      end

      it 'raises error' do
        expect { subject }.to raise_error 'require_confirm_prompt_message must be string'
      end
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
  end
end
