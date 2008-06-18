require 'xftp/progressbar'
require 'net/ftp'

class XbmcFtpClient

  F_SPACE = 10
  F_UNITS = 11

  def initialize(xbox_ip, username, password, xbox_drive, debug=false)
    @drive = xbox_drive
		
    if @ftp.nil? 
      begin
        print "Connecting to #{xbox_ip}..."
        @ftp = Net::FTP.new(xbox_ip, username, password)
        puts "done."
        puts "Using drive #{@drive}."
        puts "Available Space: #{get_bytes_free / (1024 * 1024)} MB"
      rescue => e
        abort e
      end
    end
 
    @ftp.debug_mode = debug
  end

  def put_file file_path
    filename = format_filename_for_progress_bar(file_path)
    progress = ProgressBar.new(filename,File.size(file_path))
    progress.file_transfer_mode

    size = File.size(file_path)
    inc_fraction = (Net::FTP::DEFAULT_BLOCKSIZE/size.to_f)

    @ftp.putbinaryfile(file_path) { |data|
        progress.inc Net::FTP::DEFAULT_BLOCKSIZE

    }
    progress.finish

  rescue => err
    puts err 
    abort
  end

  def get_file file_path
    progress = ProgressBar.new(file_path,@ftp.size(file_path))
    progress.file_transfer_mode

    @ftp.getbinaryfile(file_path) { |data|
        progress.inc Net::FTP::DEFAULT_BLOCKSIZE
    }
    progress.halt
  end

  def format_filename_for_progress_bar file_path
    filename = File.split(file_path)[1]
    if filename.length > 4
      filename = filename[0,filename.length - 4]

      if filename.length > 13
        filename = filename[filename.length-13,filename.length]
      end
    end

    filename
  end

  def get_filenames folder
    @ftp.chdir "/#{@drive}/#{folder}"
    filenames = @ftp.nlst
    filenames.sort!
  end

  def upload_file(folder, filename)
    if (File.size(filename) < get_bytes_free)
      @ftp.chdir "/#{@drive}/#{folder}"
      put_file(filename)
    else
      raise "Not enough space on drive #{@drive}"
    end

  rescue => err
    puts err
  end

  def upload_folder(folder)
    if (!File.exist?(folder) || !File.directory?(folder))
      puts "#{folder} is not a directory"
      abort
    end

    if File.size?(folder) > get_bytes_free
      puts "Not enough space on drive #{@drive}"
      abort
    end

    begin
      @ftp.chdir "/#{@drive}/#{folder}"
      @ftp.mkdir File.split(folder)[1]
    rescue
      puts "This directory already exists on drive #{@drive}, continue? (y/n)"
      answer = $stdin.gets.chomp!.downcase
      unless answer == "y"
        exit
      end
    end

    @ftp.chdir "/#{@drive}/#{File.split(folder)[1]}"
    get_local_filenames(folder).each {|filename|
      put_file(folder + '/' + filename)
    }

  end
  
  def get_local_filenames folder
    files = []
    Dir.new(folder).each {|filename|
      unless filename == "." || filename == ".."
        files << filename
      end
    }

    files.sort!
  end

  def download_file(folder, filename)
    @ftp.chdir "/#{@drive}/#{folder}"
    get_file(filename)

  rescue => err
    puts err
    abort
  end

  def download_folder folder
    Dir.mkdir folder
    Dir.chdir folder
    get_filenames(folder).each { |file|
      get_file(file)
    }
    Dir.chdir ".."
  rescue => err
    puts err
  end

  def get_bytes_free
    parse_bytes_free(@ftp.free_space)
  end

  def parse_bytes_free space_string

    case @drive
    when 'F'
      space = space_string.split[F_SPACE].to_f
      units = space_string.split[F_UNITS]
    else
      abort "xbox drive not supported:" + @drive
    end

    if units == "GB]"
      return space * 1024 * 1024 * 1024
    elsif units == "MB]"
      return space * 1024 * 1024
    elsif units == "KB]"
      return space * 1024
    elsif units == "bytes]"
      return space
    end

  rescue => err
    puts "Error parsing drive space"
    puts err
    abort
  end


  private :put_file, :get_file, :get_filenames, :get_local_filenames, :get_bytes_free
  private :parse_bytes_free, :format_filename_for_progress_bar

end

class Net::FTP

  #
  # Disk usage is provided in the response
  #
  def free_space
    synchronize do
      conn = transfercmd("LIST")
      #conn.close
      @space = getmultiline
    end

    return @space
  end
end
