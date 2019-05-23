require 'rack/test'
require_relative '../../../../lib/sidekiq_adhoc_job/web/routes/jobs/index'

RSpec.describe 'GET /adhoc_jobs' do
  include Rack::Test::Methods
  include_context 'SidekiqAdhocJob setup'
  include_context 'request setup'

  it 'returns list of workers and arguments' do
    get '/adhoc-jobs'

    expect(last_response.status).to eq 200

    response_body = compact_html(last_response.body)

    expect(response_body).to include('<h3>Adhoc Jobs</h3>')

    expect(response_body).to include(compact_html(
      <<~HTML
      <tr>
        <td>DummyWorker</td>
        <td>dummy</td>
        <td>id, overwrite</td>
        <td>retry_job, retries, interval</td>
        <td class="text-center">
          <a class="btn btn-warn btn-xs" href="/adhoc-jobs/dummy_worker">
            Run Job
          </a>
        </td>
      </tr>
      HTML
    ))
  end

end
