require 'sidekiq'

class DummyNoArgWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'dummy'

  def perform
  end

end
