require File.dirname(__FILE__) + '/command.rb'

class TarballFetcher
	def initialize(home_dir)
		@command = Command.new(home_dir)
	end

	def fetch(target_dir, target)
		if File.directory?("#{target_dir}/#{target.module}")
			@command.error("target version #{target.version} is already installed")
		end

		@command.execute "#{target_dir}",
			    "wget #{target.tarball_url}",
				"error fetching tarball for target #{target_version}",
				false

		@command.execute "#{target_dir}",
			    "tar xzvf #{target.tarball_url} mono",
				"error unarchiving tarball for target #{target_version}",
				false
	end
end
