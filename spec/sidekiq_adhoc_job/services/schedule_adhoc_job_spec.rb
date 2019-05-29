require_relative '../../../lib/sidekiq_adhoc_job/services/schedule_adhoc_job'

RSpec.describe SidekiqAdhocJob::ScheduleAdhocJob do
  include_context 'SidekiqAdhocJob setup'

  subject { described_class }

  let(:job_name) { 'dummy_worker' }
  let(:params) { { 'id' => 'a937de5f-c86a-4f49-9243-d1c3bad2488f', 'overwrite' => 'true', 'retry_job' => 'true', 'retries' => '10', 'interval' => '2.5' } }

  describe '#call' do
    it 'schedules job to run asynchronously' do
      scheduler = subject.new(job_name, params)

      expect(DummyWorker).to receive(:perform_async).with('a937de5f-c86a-4f49-9243-d1c3bad2488f', true, true, 10, 2.5)
      scheduler.call
    end
  end

end
