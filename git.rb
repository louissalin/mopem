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

	def update(target_dir, target)
		@command.error("cannot update from tarball source") unless target.is_from_repository?

		if !File.directory?("#{target_dir}/#{target.module}/.git")
			@command.error("target version #{target.version} is not installed")
		end

		@command.execute "#{target_dir}/#{target.module}",
			    "git reset --hard",
				"error reseting git repo for target #{target.version}",
				false

		@command.execute "#{target_dir}/#{target.module}",
			    "git clean -df",
				"error cleaning git repo for target #{target.version}"

		@command.execute "#{target_dir}/#{target.module}",
			    "git checkout #{target.branch}",
				"error checking out branch #{target.branch}"

		@command.execute"#{target_dir}/#{target.module}",
				'git pull',
				 "error pulling from git repo for target #{target.version}"
	end
end
