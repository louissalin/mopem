require File.dirname(__FILE__) + '/targets.rb'

class Utils
	def initialize(home_dir = nil)
		@home_dir = home_dir
	end

	def command(dir, cmd, error_msg, append_err_msg = true)
		redirect_symbol = '>'
		if append_err_msg
			redirect_symbol = '>>'
		end

		puts "cd #{dir} && #{cmd} 1#{redirect_symbol}#{@home_dir}/install.log 2>#{@home_dir}/error.log"
		if !system("cd #{dir} && #{cmd} 1#{redirect_symbol}#{@home_dir}/install.log 2>#{@home_dir}/error.log")
			error error_msg + ". Please check #{@home_dir}/error.log for details"
		end
	end

	def error(msg)
		puts 'error: ' + msg
		exit 1
	end

	def get_mono_prefix(target)
		if target.module == 'mono'
			"#{@home_dir}/install/mono-#{target.version}"
		else
			mono_target = get_mono_target
			"#{@home_dir}/install/mono-#{mono_target.version}"
		end
	end

	def is_apt_get_available
		`which apt-get`.length > 0
	end

	def is_zypper_available
		`which zypper`.length > 0
	end

	private
	def get_mono_target
		current_mono_version = ENV['MOPEM_CURRENT_MONO_VERSION']
		if current_mono_version == nil 
			error 'please use a mono target before installing other targets' 
		end

		TargetFetcher.new.get_target('mono', current_mono_version)
	end
end
