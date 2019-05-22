module SidekiqAdhocJob
  class WorkerFilesLoader

    WORKER_PATH_PATTERN ||= SidekiqAdhocJob.config.worker_path_pattern.freeze

    @_worker_files = []

    def self.load
      Dir[WORKER_PATH_PATTERN].reject { |file_name| file_name.match(/spec/) }.sort.each do |file_name|
        @_worker_files << file_name unless @_worker_files.include?(file_name)
      end
    end

    def self.worker_files
      @_worker_files
    end

    def self.find_file(file_name)
      @_worker_files.find { |file| file.match(file_name) }
    end

  end
end
