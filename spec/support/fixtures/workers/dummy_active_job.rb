module ActiveJob
  class Base; end
end

module SidekiqAdhocJob
  module RailsTest
    class DummyActiveJob < ActiveJob::Base
    end
  end
end
