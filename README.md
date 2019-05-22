# Sidekiq Adhoc Job for Sidekiq Web UI

This is an extension to the Sidekiq Web UI, which allows triggering jobs on adhoc basis.

To enable this extension, insert this piece of code in your app at the initialization stage:

```
require 'sidekiq_adhoc_job'

SidekiqAdhocJob.configure do |config|
  config.worker_path_pattern = 'lib/your_project/workers/**/*.rb'
end
SidekiqAdhocJob.init
```
