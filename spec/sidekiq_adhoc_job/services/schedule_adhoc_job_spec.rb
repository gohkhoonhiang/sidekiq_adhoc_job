require_relative '../../../lib/sidekiq_adhoc_job/services/schedule_adhoc_job'

RSpec.describe SidekiqAdhocJob::ScheduleAdhocJob do
  include_context 'SidekiqAdhocJob setup'

  subject { described_class }

  let(:job_name) { 'sidekiq_adhoc_job_test_dummy_worker' }
  let(:params) do
    {
      'id' => 'a937de5f-c86a-4f49-9243-d1c3bad2488f',
      'overwrite' => 'true',
      'retry_job' => 'true',
      'retries' => '10',
      'interval' => '2.5',
      'name' => 'nil',
      'options' => '{ "skip_check": true }',
      'type' => 'foo'
    }
  end

  describe '#call' do
    let(:expected_params) do
      ['a937de5f-c86a-4f49-9243-d1c3bad2488f', true, true, 10, 2.5, nil, { skip_check: true }]
    end
    let(:expected_kw_params) do
      {
        type: 'foo'
      }
    end

    it 'schedules job to run asynchronously' do
      scheduler = subject.new(job_name, params)

      expect(SidekiqAdhocJob::Test::DummyWorker).to receive(:perform_async).with(*expected_params, **expected_kw_params)
      scheduler.call
    end

    context 'with override' do
      let(:params) do
        {
          override_args: 'let_me_override',
          positional_args: positional_args.to_json,
          keyword_args: keyword_args.to_json
        }
      end

      let(:positional_args) do
        ['a937de5f-c86a-4f49-9243-d1c3bad2488f', true, true, 10, 2.5, nil, { skip_check: true }]
      end

      let(:keyword_args) do
        {
          type: 'foo'
        }
      end

      it 'schedules job to run asynchronously' do
        scheduler = subject.new(job_name, params)

        expect(SidekiqAdhocJob::Test::DummyWorker).to receive(:perform_async).with(*expected_params, **expected_kw_params)
        scheduler.call
      end
    end

    context 'with override but empty params' do
      let(:params) do
        {
          override_args: 'let_me_override',
          positional_args: '',
          keyword_args: ''
        }
      end

      let(:expected_params) { [] }
      let(:expected_kw_params) { {} }

      it 'schedules job to run asynchronously' do
        scheduler = subject.new(job_name, params)

        expect(SidekiqAdhocJob::Test::DummyWorker).to receive(:perform_async).with(*expected_params, **expected_kw_params)
        scheduler.call
      end
    end
  end

end
