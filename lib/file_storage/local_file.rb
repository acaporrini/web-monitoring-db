include ActionDispatch::Routing::UrlFor
include Rails.application.routes.url_helpers

module FileStorage
  # Store and retrieve files from the local filesystem.
  class LocalFile
    # Creates a new LocalFile store.
    # +path+ Specifies the directory in which to store files. If not specified,
    #        files will be stored in a random-named temporary directory.
    # +tag+  Controls naming of temporary directories. If specified, temporary
    #        directory names will be prefixed with this.
    def initialize(path: nil, tag: 'storage')
      @directory = path
      @tag = tag
      @ensured = false
    end

    def directory
      @directory ||= Dir.mktmpdir "web-monitoring-db--#{@tag}"
    end

    def get_file(path)
      File.read(full_path(path))
    end

    def save_file(path, content, _options = nil)
      ensure_directory
      File.open(full_path(path), 'wb') do |file|
        content_string = content.try(:read) || content
        file.write(content_string)
      end
    end

    def url_for_file(path)
      raw_index_url = polymorphic_url('api_v0_raw_index')
      "#{raw_index_url}/#{path}"
    end

    def contains_url?(url_string)
      if url_string.starts_with?('http://') || url_string.starts_with?('https://')
        path = url_string.split('/')[-1]
        File.exist? full_path(path)
      else
        false
      end
    end

    private

    def full_path(path)
      File.join(directory, path)
    end

    def ensure_directory
      unless @ensured
        @ensured = true
        FileUtils.mkdir_p directory
      end
      directory
    end
  end
end
