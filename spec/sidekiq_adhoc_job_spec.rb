require_relative '../lib/sidekiq_adhoc_job'

SPEC_WORKER_PATH = 'spec/support/fixtures/workers/**/*.rb'.freeze

RSpec.describe SidekiqAdhocJob do
  include_context 'SidekiqAdhocJob setup'
  let(:init_first?) { false }

  subject { described_class }

  describe '.config' do
    it 'returns configuration object' do
      expect(subject.config).to be_an_instance_of(SidekiqAdhocJob::Configuration)
    end
  end

  describe '.configure' do
    it 'yields configuration object' do
      expect { |blk| subject.configure(&blk) }.to yield_with_args(instance_of(SidekiqAdhocJob::Configuration))
    end

    context 'when require_confirm_prompt_message is not string' do
      subject do
        described_class.configure { |config| config.require_confirm_prompt_message = { 'not' => %w[a string] } }
      end

      it 'raises error' do
        expect { subject }.to raise_error 'require_confirm_prompt_message must be string'
      end
    end

    context '#require_confirm_worker_names' do
      let(:config) { subject.config }

      context 'when given list of Strings' do
        let(:require_confirm_worker_names) { %w[Test::IncludedWorker] }

        it 'returns all matching worker names' do
          expect(config.require_confirmation?('Test::IncludedWorker')).to eq true
          expect(config.require_confirmation?('Test::NotIncludedWorker')).to eq false
        end
      end

      context 'when given list of Symbols' do
        let(:require_confirm_worker_names) { %i[Test::IncludedWorker] }

        it 'returns all matching worker names' do
          expect(config.require_confirmation?('Test::IncludedWorker')).to eq true
          expect(config.require_confirmation?('Test::NotIncludedWorker')).to eq false
        end
      end

      context 'when given a Proc' do
        let(:require_confirm_worker_names) { ->(worker_name) { worker_name.start_with?('Test') } }

        it 'returns all matching worker names' do
          expect(config.require_confirmation?('Test::DummyWorker')).to eq(true)
          expect(config.require_confirmation?('NoTest::DummyWorker')).to eq(false)
        end
      end

      context 'when given a Class that implements #call' do
        class self::CallableObject
          def call(worker_name)
            worker_name.end_with?('Job')
          end
        end

        let(:require_confirm_worker_names) { self.class::CallableObject.new }

        it 'returns all matching worker names' do
          expect(config.require_confirmation?('Test::DummyJob')).to eq(true)
          expect(config.require_confirmation?('Test::DummyWorker')).to eq(false)
        end
      end
    end
  end

  describe '.init' do
    context 'configure first' do
      let(:module_names) { %i[SidekiqAdhocJob::Test SidekiqAdhocJob::OtherTest SidekiqAdhocJob::Test::Worker] }

      it 'loads worker files and adds web extension' do
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
        expect(subject.config.module_names).to eq [
          'SidekiqAdhocJob::Test',
          'SidekiqAdhocJob::OtherTest',
          'SidekiqAdhocJob::Test::Worker'
        ]
      end
    end

    context 'different strategy: active_job' do
      let(:module_names) { %i[SidekiqAdhocJob::ActiveJobTest] }
      let(:strategy_name) { :active_job }

      it 'loads worker files and adds web extension' do
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
      let(:module_names) { %i[SidekiqAdhocJob::RailsApplicationJobTest] }
      let(:strategy_name) { :rails_application_job }

      it 'loads worker files and adds web extension' do
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
