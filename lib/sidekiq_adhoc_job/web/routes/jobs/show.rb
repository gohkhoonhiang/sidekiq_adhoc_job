module SidekiqAdhocJob
  module Web
    module Jobs
      class Show

        def self.register(app)
          app.get '/adhoc-jobs/:name' do
            @csrf_token = env['rack.session'][:csrf]
            @presented_job = SidekiqAdhocJob::JobPresenter.find(params[:name])
            if @presented_job
              erb File.read(File.join(VIEW_PATH, 'jobs/show.html.erb'))
            else
              redirect "#{root_path}adhoc-jobs"
            end
          end
        end

      end
    end
  end
end
