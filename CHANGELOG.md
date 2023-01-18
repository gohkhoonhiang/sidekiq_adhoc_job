# Change Log

## 2.2.2

- Allow configuration option `require_confirm_prompt_message` to accept a Proc or Ruby callable object.
- Alert with error if challenge keyword is incorrect.

## 2.2.1

- Add configuration option for `require_confirm_prompt_message` to prompt user to input a challenge keyword when attempting to run workers that require confirmation.

## 2.2.0

- Add configuration option for `require_confirm_worker_names` to specify worker class names that require confirmation to run.

## 2.1.1

- Sort job classes alphabetically in web view

## 2.1.0

- Support keyword arguments for ActiveJob#perform
- Fix #perform parameters lookup when a job has prepended module and also inherits a class,
  eg. ActiveJob implementations
- Fix typos in README

## 2.0.0 (Potential breaking change)

Official release.

- Support Ruby 3.

## 2.0.0.pre (Potential breaking change)

Prelease for v2.0.0.

- Support Ruby 3.

## 1.0.1

- Update README for new option for `strategy`.
- Update README for usage of rest arguments in Web UI.

## 0.3.1

- Update README for new option for `strategy`.
- Update README for usage of rest arguments in Web UI.

## 1.0.0 (Potential breaking change)

- Update dependency versions
  - sidekiq: constraint to < 7, supports Sidekiq 6

## 0.3.0

- Update dependency versions
  - ruby: constraint to < 2.7.x, more work required to check for 2.7.x compatibility
  - sidekiq: constraint to < 5, more work required to check for 6 compatibility
  - rspec: update to latest 3.10.0
  - mock_redis: update to latest 0.26.0
- [Web UI] Temporarily remove required constraint for rest arguments.
- [Rails] Support ApplicationJob strategy.

## 0.2.2
- Allow empty values for optional arguments in the web UI.
  - If empty values are sent, do not pass them to the worker, so that default values will be used instead.
  - Note: if the default value is non-empty, it's not possible to set an empty value.

## 0.2.1

- Support ActiveJob worker classes loading.
- Add configuration option for `load_paths` to specify worker class files loading.
- Job params from the adhoc job schedule web UI are deep symbolized.
- Minor updates to adhoc job schedule web UI:
  - Display worker class name.
  - Detailed description for rest arguments input.

## 0.2.0 (Bad release)

## 0.1.6

- Improve worker class loading so that it doesn't display deprecation warning (eg. `warning: constant ::Fixnum is deprecated`) when using Ruby 2.6
- Updated configuration options:
  - `module_names` is no longer required.

## 0.1.5

- Fix worker class loading to check for included module `Sidekiq::Worker`, instead of relying on regex match on the class name
  - Now it can detect class names containing all capital letters, eg. `CSVWorker`
  - Now it doesn't need to rely on the class names containing `Worker` suffix
  - Now it doesn't wrongly load a class whose name ends with `Worker`, but isn't actually a Sidekiq worker

## 0.1.4

- Fix parameters inference for workers with prepended modules
  - Create a separate class inspector util that recursively gets super class method parameters
- Add support for `nil` and JSON string parsing

## 0.1.3

- Fix adhoc job trigger form to take all arguments as required input
  - There is no easy way to figure out at runtime what are the default values of optional arguments, so we will always ask for all argument values

## 0.1.2

- Fix gemspec to include `*.erb` and `*.yml` files

## 0.1.1

- Fix worker classes loading logic
  - Instead of reading files and guessing the worker class names, use `.constants` to get actual worker class names
  - Configuration of the modules to read from required, eg. `[:'YourProject::YourWorkerNamespace']` will read any worker class defined within `YourProject::YourWorkerNamespace` namespace
- Setup Travis CI

## 0.1.0

Initial release. Features include:

- Add `Adhoc Jobs` tab to Sidekiq Web UI
- Read worker files defined in the configuration and display a list of workers and their respective required and optional arguments
- Allow triggering a job with arguments from the Web UI, it will always be run asynchronously
- Basic argument parsing:
  - integer string to integer
  - float string to float
  - true/false string to boolean
  - string as-is
- Test cases for:
  - Configuration and initialization
  - UI view presenter
  - Adhoc job scheduling service
  - Adhoc Jobs Web UI actions
    - List jobs
    - List Job
    - Trigger Job
