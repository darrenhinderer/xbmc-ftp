require 'xftp/config_reader'
require 'xftp/media_transporter'
require 'xftp/downloads_scanner'

class Xftp
  def initialize

    config = ConfigReader.new
    @media = MediaTransporter.new(config.get(:xbox_ip), 
      config.get(:username), config.get(:password), config.get(:xbox_drive), 
      config.get(:videos_folder))
    @scanner = DownloadsScanner.new(config.get(:downloads_folder))
  end

  def run
    loop do
      print "xftp> "
      cmd = gets.chomp

      case cmd
      when "video"
        @scanner.scan
        print "selection #: "
        selection = gets.to_i
        upload_video selection
      when "quit"
        break
      when "help"
        print_help
      else
        print_help
      end
    end
  end

  def upload_video video_number
    @media.upload_video(@scanner.get_video_path(video_number))
  rescue => e
    puts e
  end

  def print_help
    puts "options are: video, help, quit"
  end
end
