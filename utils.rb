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

		#puts "cd #{dir} && #{cmd} 1#{redirect_symbol}#{@home_dir}/install.log 2>#{@home_dir}/error.log"
		if !system("cd #{dir} && #{cmd} 1#{redirect_symbol}#{@home_dir}/install.log 2>#{@home_dir}/error.log")
			error error_msg + ". Please check #{@home_dir}/error.log for details"
		end
	end

	def error(msg)
		puts 'error: ' + msg
		exit 1
	end

	def get_mono_prefix(target)
		"#{@home_dir}/install/mono-#{target.version}"
	end

	def create_environment_script(target)
		mono_prefix = get_mono_prefix(target)
		gnome_prefix ='/usr'
		script_path = target.source_dir + '/mono-environment'

		File.open(script_path, 'w') do |f|
			f.puts "export DYLD_LIBRARY_FALLBACK_PATH=#{mono_prefix}/lib:$DYLD_LIBRARY_FALLBACK_PATH"
			f.puts "export LD_LIBRARY_PATH=#{mono_prefix}/lib:$LD_LIBRARY_PATH"
			f.puts "export C_INCLUDE_PATH=#{mono_prefix}/include:#{gnome_prefix}/include"
			f.puts "export ACLOCAL_PATH=#{mono_prefix}/share/aclocal"
			f.puts "export PKG_CONFIG_PATH=#{mono_prefix}/lib/pkgconfig:#{gnome_prefix}/lib/pkgconfig"
			f.puts "export PATH=#{mono_prefix}/bin:$PATH"
			f.puts "PS1=\"[mono-#{target.version}] $PS1\""
		end

		# return bash command to execute script
		". #{script_path}"
	end

end
