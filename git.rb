require File.dirname(__FILE__) + '/command.rb'

class GitFetcher
	def initialize(home_dir)
		@command = Command.new(home_dir)
	end

	def fetch(target_dir, target)
		if File.directory?("#{target_dir}/#{target.module}/.git")
			@command.error("target version #{target.version} is already installed")
		end

		@command.execute "#{target_dir}",
			    "git clone #{target.repository}",
				"error cloning git repo for target #{target_version}",
				false
	end
end
