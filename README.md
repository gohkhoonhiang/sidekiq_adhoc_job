# Sidekiq Adhoc Job for Sidekiq Web UI

This is an extension to the Sidekiq Web UI, which allows triggering jobs on adhoc basis.

## Build Information

[![Build Status](https://travis-ci.org/gohkhoonhiang/sidekiq_adhoc_job.svg?branch=master)](https://travis-ci.org/gohkhoonhiang/sidekiq_adhoc_job)

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
  config.strategy_name = :active_job
  config.load_paths = ['app/jobs/**/*.rb']
end
SidekiqAdhocJob.init
```

Options:

- `module_names` (optional): takes in a list of module names that include the worker classes to be loaded. When not provided, or an empty list is provided, *ALL* worker classes loaded by your app will be included.
- `strategy_name` (optional): takes a symbol representing the strategy to use to load worker classes
  - `default` (default): check for all classes that include `Sidekiq::Worker`
  - `active_job`: check for all classes that extend `ActiveJob::Base`
  - `rails_application_job`: check for all classes that extend `ApplicationJob`
- `load_paths` (optional - default `[]`): takes in a list of file paths that the gem should load when initializing, in order to include the necessary classes in the app `ObjectSpace`
- `require_confirm_worker_names` (optional - default `[]`): takes in a list of fully namespaced worker class names that the web UI will request for confirmation before running the job

### Keyword Arguments Support (>= v2.1.0)

Not that only ActiveJob supports keyword arguments for #perform, because it does additional serialization work. Sidekiq::Worker by default does not.

So even though SidekiqAdhocJob allows for displaying keyword arguments input in the Web UI,
it will raise error when invoking the worker's #perform with the keyword arguments.

## Web UI

The web UI is accessible via `#{root_url}/#{sidekiq_web_path}/adhoc-jobs`. A list of loaded jobs will be displayed in a table:
- Job Name
- Job Queue
- Required Arguments
- Optional Arguments
- Required Keyword Arguments
- Optional Keyword Arguments
- Has Rest Arguments
- Confirm Required
- Actions

### Run Job

To run a job, click `View Job`, then fill in the required parameters and optionally the optional parameters, then click `Run Job`.

Empty values in the optional parameters will be ignored, and the default values specified in the worker will be used to run the job.

Note: If the default value is non-empty, you will not be able to set an empty value to override the default, since an empty value will be ignored.

For rest arguments, provide a JSON string containing the keyword arguments, eg.

```json
{ "user_id": "123-456-789" }
```

Note: There is no UI validation for the input, as the class inspector will not be able to infer what are the fields in the rest arguments list.

### Require Confirmation

If the `require_confirm_worker_names` option is configured with the worker class name of the job you want to run, it will prompt for confirmation. By clicking `OK`, the job will be scheduled to run; otherwise, it will not run. This helps to prevent accidentally running a critical job when not meant to be.
