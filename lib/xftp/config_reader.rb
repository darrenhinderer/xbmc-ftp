require 'yaml'

class ConfigReader

  LINUX_CONFIG_PATH = "/home/#{ENV['USER']}/xftp.yml"
  WINDOWS_CONFIG_PATH = "C:/xftp.txt"

  DEFAULT_WINDOWS_DOWNLOADS = "C:/Downloads/"
  DEFAULT_LINUX_DOWNLOADS = "/home/#{ENV['USER']}/Desktop"

  def initialize
    @config = read_config
  rescue => e
 
    if windows? 
      write_defaults(DEFAULT_WINDOWS_DOWNLOADS)
    else
      write_defaults(DEFAULT_LINUX_DOWNLOADS)
    end

    puts "Go modify the configuration file now, and type xftp to restart." 
    exit
  end

  def get(key)
    @config[key.to_s]
  end

  def write_defaults(downloads_folder)
    config = { "username" => "xbox", 
               "password" => "xbox",
               "xbox_ip" => "192.168.1.100",
               "downloads_folder" => downloads_folder,
               "xbox_drive" => "F",
               "videos_folder" => "Videos" }

    if windows?
      write_config(WINDOWS_CONFIG_PATH, config)
    else
      write_config(LINUX_CONFIG_PATH, config)
    end
  end

  def write_config(path, config)
    puts "Writing default configuration to: " + path

    File.open(path, 'w') do |out|
      YAML.dump(config, out)
    end
  end

  def read_config
    if windows?
      YAML.load_file(WINDOWS_CONFIG_PATH)
    else
      YAML.load_file(LINUX_CONFIG_PATH)
    end
  end

  def windows?
    processor, platform, *rest = RUBY_PLATFORM.split("-")
    platform == 'mswin32'
  end

end
