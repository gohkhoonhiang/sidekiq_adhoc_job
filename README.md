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
  config.module_names = ['YourProject::Worker']
  config.ignore_spec = true
end
SidekiqAdhocJob.init
```

Options:

- `module_names`: takes in a list of module names that include the worker classes to be loaded, required
- `ignore_spec`: do not include any worker files created in the `spec` directory or has the `spec` keyword in the file name, default to `true`

Without first configuring, it will raise `SidekiqAdhocJob::InvalidConfigurationError` when `SidekiqAdhocJob.init` is called.
