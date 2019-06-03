module SharedWorker

  def logger
    Sidekiq.logger
  end

end
