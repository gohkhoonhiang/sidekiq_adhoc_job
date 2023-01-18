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

  config.require_confirm_worker_names     = %w[YourProject::Worker::A YourProject::Worker::B]
  # List of Symbols                       = %i[YourProject::Worker::A YourProject::Worker::B]
  # Apply to workers name ending with "A" = ->(worker_class) { worker_class.end_with?('A') }
  # Ruby class that implements #call      = CallableObject.new
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
- `require_confirm_worker_names` (optional - default `[]`): takes in a Ruby callable object, or a Proc, or fully namespaced worker class names that require confirmation before running the job through web UI.
- `require_confirm_prompt_message` (optional - default `confirm`): takes a string that is used for challenge keyword before running jobs included in `require_confirm_worker_names`. This value must be a string, otherwise, an error with message `'require_confirm_prompt_message must be string'` will be raised

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

If you're using sidekiq adhoc jobs in Production, you may want to consider using this configuration as an extra protection against erroneously running a sidekiq job. Once turned on, the user will be required to enter a challenge keyword in a prompt before the job can be run through the admin UI.

To use this feature, add the worker class name of the jobs you would like to add the confirmation for into the `require_confirm_worker_names` option.

The challenge keyword is set to be `confirm` as default, if you would like to configure the challenge keyword, you can use the `require_confirm_prompt_message` option.
