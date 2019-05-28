module SidekiqAdhocJob
  module Web
    module Jobs
      class Schedule

        def self.register(app)
          app.post '/adhoc-jobs/:name/schedule' do
            SidekiqAdhocJob::ScheduleAdhocJob.new(params[:name], request.params).call
            redirect "#{root_path}adhoc-jobs"
          end
        end

      end
    end
  end
end
