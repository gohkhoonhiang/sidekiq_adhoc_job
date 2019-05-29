# Sidekiq Adhoc Job for Sidekiq Web UI

This is an extension to the Sidekiq Web UI, which allows triggering jobs on adhoc basis.

## Installation

```
gem install sidekiq_adhoc_job
```

## Usage

To enable this extension, insert this piece of code in your app at the initialization stage:

```ruby
require 'sidekiq_adhoc_job'

SidekiqAdhocJob.configure do |config|
  config.worker_path_pattern = 'lib/your_project/workers/**/*.rb'
  config.ignore_spec = true
end
SidekiqAdhocJob.init
```

Options:

- `worker_path_pattern`: takes in the absolute path pattern where the worker files are loaded, required
- `ignore_spec`: do not include any worker files created in the `spec` directory or has the `spec` keyword in the file name, default to `true`

Without first configuring, it will raise `SidekiqAdhocJob::InvalidConfigurationError` when `SidekiqAdhocJob.init` is called.
