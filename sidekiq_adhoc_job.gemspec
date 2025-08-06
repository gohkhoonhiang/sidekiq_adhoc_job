# coding: utf-8
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_adhoc_job/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq_adhoc_job'
  spec.version       = SidekiqAdhocJob::VERSION
  spec.authors       = ['Goh Khoon Hiang']
  spec.email         = ['gohkhoonhiang@gmail.com']

  spec.summary       = %q{Trigger jobs adhoc from Sidekiq web admin}
  spec.description   = %q{Trigger jobs adhoc from Sidekiq web admin}
  spec.homepage      = 'https://github.com/gohkhoonhiang/sidekiq_adhoc_job'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir['lib/**/*.rb', 'lib/**/*.erb', 'lib/**/locales/*.yml']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib/sidekiq_adhoc_job', 'lib']

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'base64'
  spec.add_development_dependency 'ostruct'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 12.3.2'
  spec.add_development_dependency 'rspec', '~> 3.10.0'
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'mock_redis', '~> 0.26.0'

  spec.add_runtime_dependency 'sidekiq', '< 8'
end
