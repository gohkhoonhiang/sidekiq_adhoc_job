require_relative '../../lib/sidekiq_adhoc_job/web'

RSpec.describe SidekiqAdhocJob::Web do
  include_context 'SidekiqAdhocJob setup'

  subject { described_class }

  let(:app) { double(get: true, post: true) }

  describe '.registered' do
    it 'loads all routes and registers with app' do
      expect(SidekiqAdhocJob::Web::Jobs::Index).to receive(:register).with(app)
      expect(SidekiqAdhocJob::Web::Jobs::Show).to receive(:register).with(app)
      expect(SidekiqAdhocJob::Web::Jobs::Schedule).to receive(:register).with(app)

      subject.registered(app)
    end
  end

end
