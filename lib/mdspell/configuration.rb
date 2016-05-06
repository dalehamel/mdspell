require 'mixlib/config'

module MdSpell
  # Stores configuration from both command line and config file.
  class Configuration
    extend Mixlib::Config

    config_strict_mode true

    default :config_file, '~/.mdspell'
    default :language, 'en_US'
    default :verbose, false
    default :version, VERSION

    def self.load!(config)
      # Load optional config file if it's present.
      if config[:config_file]
        config_filename = File.expand_path(config[:config_file])
        from_file(config_filename) if File.exist?(config_filename)
      end

      # Store command line configuration options.
      merge!(config)
    end
  end
end
