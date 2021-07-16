require_relative '../../../lib/sidekiq_adhoc_job/web/job_presenter'

RSpec.describe SidekiqAdhocJob::Web::JobPresenter do
  include_context 'SidekiqAdhocJob setup'

  subject { described_class }

  describe '.build_collection' do
    it 'returns all available job presenters' do
      job_presenters = subject.build_collection
      expect(job_presenters.count).to eq 10
    end
  end

  describe '.find' do
    context 'worker file exists' do
      it 'returns found job presenter' do
        job_presenter = subject.find('sidekiq_adhoc_job_test_dummy_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::DummyWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_dummy_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i(id overwrite)
        expect(job_presenter.optional_args).to eq %i(retry_job retries interval name options)
        expect(job_presenter.required_kw_args).to eq %i(type)
        expect(job_presenter.optional_kw_args).to eq %i(dryrun)
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_namespaced_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::NamespacedWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_namespaced_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i()
        expect(job_presenter.optional_args).to eq %i()
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_worker_nested_namespaced_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::Worker::NestedNamespacedWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_worker_nested_namespaced_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i()
        expect(job_presenter.optional_args).to eq %i()
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_dummy_rest_args_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::DummyRestArgsWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_dummy_rest_args_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i(id)
        expect(job_presenter.optional_args).to eq %i()
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq true

        job_presenter = subject.find('sidekiq_adhoc_job_test_prepended_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::PrependedWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_prepended_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i(id overwrite)
        expect(job_presenter.optional_args).to eq %i(retry_job retries interval)
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_nested_prepended_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::NestedPrependedWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_nested_prepended_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i(id overwrite)
        expect(job_presenter.optional_args).to eq %i(retry_job retries interval)
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_sample_csv_worker')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::SampleCSVWorker
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_sample_csv_worker'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i()
        expect(job_presenter.optional_args).to eq %i()
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false

        job_presenter = subject.find('sidekiq_adhoc_job_test_non_explicit')
        expect(job_presenter.name).to eq SidekiqAdhocJob::Test::NonExplicit
        expect(job_presenter.path_name).to eq 'sidekiq_adhoc_job_test_non_explicit'
        expect(job_presenter.queue).to eq 'dummy'
        expect(job_presenter.required_args).to eq %i()
        expect(job_presenter.optional_args).to eq %i()
        expect(job_presenter.required_kw_args).to eq %i()
        expect(job_presenter.optional_kw_args).to eq %i()
        expect(job_presenter.has_rest_args).to eq false
      end
    end

    context 'worker file does not exist' do
      it 'returns nil' do
        expect(subject.find('invalid')).to eq nil
      end
    end
  end

end
