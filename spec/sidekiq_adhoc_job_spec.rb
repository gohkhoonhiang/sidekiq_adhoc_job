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
  end

  describe '.config' do
    it 'returns configuration object' do
      subject.configure { |config| config.module_names = [:'SidekiqAdhocJob::Test'] }
      expect(subject.config).to be_an_instance_of(SidekiqAdhocJob::Configuration)
    end
  end

  describe '.init' do
    context 'without configure first' do
      it 'raises error' do
        expect { subject.init }.to raise_error(SidekiqAdhocJob::InvalidConfigurationError)
      end
    end

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
            SidekiqAdhocJob::Test::PrependedWorker,
            SidekiqAdhocJob::Test::Worker::NestedNamespacedWorker,
            SidekiqAdhocJob::Test::SampleCSVWorker,
            SidekiqAdhocJob::Test::NonExplicit
          ]
        )
      end

      it 'transforms module names properly' do
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
  end
end
