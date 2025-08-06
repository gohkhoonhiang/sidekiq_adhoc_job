require 'rack/test'
require_relative '../../../../lib/sidekiq_adhoc_job/web/routes/jobs/show'

RSpec.describe 'GET /adhoc_jobs/:name' do
  include Rack::Test::Methods
  include_context 'SidekiqAdhocJob setup'
  include_context 'request setup'

  def check_script_csp_nonce(response_body = last_response.body)
    if Sidekiq::VERSION >= '7.3.0'
      expect(response_body).to include("nonce=\"#{last_request.env[:csp_nonce]}\"")
    end
  end

  context 'has arguments' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_worker/schedule" id="adhoc-jobs-submit-form">
          HTML
        )
      )

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="id">*id:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="id" id="id" required/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="overwrite">*overwrite:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="overwrite" id="overwrite" required/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="retry_job">retry_job:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="retry_job" id="retry_job"/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="retries">retries:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="retries" id="retries"/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="interval">interval:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="interval" id="interval"/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="name">name:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="name" id="name"/>
              </div>
            </div>
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="options">options:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="options" id="options"/>
              </div>
            </div>
          HTML
        )
      )

      check_script_csp_nonce(response_body)
    end
  end

  context 'has rest args' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_rest_args_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_rest_args_worker/schedule" id="adhoc-jobs-submit-form">
          HTML
        )
      )

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="id">*id:</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="id" id="id" required/>
              </div>
            </div>
          HTML
        )
      )

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <div class="form-group row">
              <label class="col-sm-2 col-form-label" for="rest_args">Rest arguments (please provide a json string representing the arguments):</label>
              <div class="col-sm-4">
                <input class="form-control" type="text" name="rest_args" id="rest_args"/>
              </div>
            </div>
          HTML
        )
      )

      check_script_csp_nonce(response_body)
    end
  end

  context 'no argument' do
    it 'generates form for running job' do
      get '/adhoc-jobs/sidekiq_adhoc_job_test_dummy_no_arg_worker'

      expect(last_response.status).to eq 200

      response_body = compact_html(last_response.body)

      expect(response_body).to include(
        compact_html(
          <<~HTML
            <form method="POST" action="/adhoc-jobs/sidekiq_adhoc_job_test_dummy_no_arg_worker/schedule" id="adhoc-jobs-submit-form">
          HTML
        )
      )

      expect(response_body).to include('<p>No job arguments</p>')

      check_script_csp_nonce(response_body)
    end
  end

  context 'job not found' do
    it 'redirects to index page' do
      get '/adhoc-jobs/invalid_worker'

      expect(last_response.status).to eq 302
      expect(last_response.headers['Location']).to eq "#{last_request.base_url}/adhoc-jobs"
    end
  end
end
