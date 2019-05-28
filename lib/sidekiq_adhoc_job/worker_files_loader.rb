module SidekiqAdhocJob
  class WorkerFilesLoader

    @_worker_files = []

    def self.load(worker_path_pattern)
      Dir[worker_path_pattern].reject do |file_name|
        file_name.match(/spec/) && SidekiqAdhocJob.config.ignore_spec
      end.sort.each do |file_name|
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
