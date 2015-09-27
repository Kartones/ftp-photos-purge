#!/usr/bin/env ruby

require 'date'
require "net/ftp"
require_relative "config"

class FTPPhotosPurge

	def run
		max_allowed_date = Date.today - DAYS_TO_KEEP

		puts "Going to purge files older than #{max_allowed_date} from #{FTP_HOST}"

		ftp = Net::FTP.new(FTP_HOST)
		ftp.debug_mode = FTP_DEBUG_MODE

		ftp.login(FTP_USERNAME, FTP_PASSWORD)
		ftp.chdir(WORKING_FOLDER) unless WORKING_FOLDER.nil?
		ftp.list("*") do |file|
			if (/\.php$/ =~ file).nil?
				file_date = Date.strptime(file.slice(0,8), '%m-%d-%y')
				if (max_allowed_date.to_time.to_i - file_date.to_time.to_i > 0)
					file_name = file.slice(39,file.length)
					puts "Deleting file #{file_name}"
					 unless DRY_RUN
					 	begin
							ftp.delete(file_name)
						rescue => exception
							puts "Error deleting #{file_name}: #{exception.message}"
						end
					end
				end
			end
		end

		ftp.close

		puts "Purge finished"
	end
end

begin
	FTPPhotosPurge.new.run
end
