require 'xftp/xbmc_ftp_client'

class MediaTransporter
  def initialize(xbox_ip, username, password, xbox_drive, videos_folder)
    @xbmc = XbmcFtpClient.new(xbox_ip, username, password, xbox_drive)

    @videos_folder = videos_folder
  end

  def upload_video filename
    @xbmc.upload_file(@videos_folder, filename)
  end

  def upload_video_folder folder_name
    @xbmc.upload_folder(@videos_folder, folder_name)
  end
end

