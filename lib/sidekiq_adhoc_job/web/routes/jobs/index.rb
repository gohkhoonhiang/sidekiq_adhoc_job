module SidekiqAdhocJob
  module Web
    module Jobs
      class Index

        def self.register(app)
          app.get '/adhoc-jobs' do
            @presented_jobs = SidekiqAdhocJob::Web::JobPresenter.build_collection.sort_by { |j| j.name.to_s }

            erb File.read(File.join(VIEW_PATH, 'jobs/index.html.erb'))
          end
        end

      end
    end
  end
end
