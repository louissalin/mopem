class Command
	def initialize(home_dir)
		@home_dir = home_dir
	end

	def execute(dir, cmd, error_msg, append_err_msg = true)
		redirect_symbol = '>'
		if append_err_msg
			redirect_symbol = '>>'
		end

		if !system("cd #{dir} && #{cmd} 1#{redirect_symbol}#{@home_dir}/install.log 2>#{@home_dir}/error.log")
			error error_msg + ". Please check #{@home_dir}/error.log for details"
		end
	end

	def error(msg)
		puts 'error: ' + msg
		exit 1
	end

end
