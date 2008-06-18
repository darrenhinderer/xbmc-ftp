require 'find'

class DownloadsScanner

  VIDEO_EXTENSIONS = "avi" + "mpg" + "mov" + "mpeg" + "wmv"
	
  def initialize(downloads_folder)
    @downloads = downloads_folder
    @videos = []
  end

  def scan
    @videos = []
    @folders = []

    Find.find(@downloads) do |path|
      if is_file?(path) && is_video?(path)
        @videos << path
      end
    end

    @videos.sort!

    count = 1
    for path in @videos
      filename = File.split(path)[1]
      puts count.to_s + ". " + filename + " " + file_size(path)
      count += 1
    end
  end

  def get_video_path number
    if number <= 0 || number > @videos.length
      raise "Not a valid choice."
    end

    @videos[number-1].to_s
  end

  def is_video? file
    extension = file.split('.')[file.split('.').length-1].downcase

    if VIDEO_EXTENSIONS.include?(extension)
      true
    else
      false
    end
  end

  def is_file? path
    if File.directory?(path)
      false
    else
      true
    end
  end

  def file_size path
    megabytes = File.size(path)/(1024*1024)
    megabytes.to_s + " MB"
  end

=begin
  def folder_size path
    size = 0
    Dir.foreach(path) { |file| size += File.size(path + '/' + file)}
    
    megabytes = size/(1024*1024)
    megabytes.to_s + " MB"
  end
=end

end
