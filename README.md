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
end
SidekiqAdhocJob.init
```

or if no module names to whitelist:

```ruby
require 'sidekiq_adhoc_job'

SidekiqAdhocJob.configure {}
SidekiqAdhocJob.init
```

Options:

- `module_names`: takes in a list of module names that include the worker classes to be loaded. When not provided, or an empty list is provided, *ALL* worker classes loaded by your app will be included.
