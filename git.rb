require File.dirname(__FILE__) + '/utils.rb'

class GitFetcher
	def initialize(home_dir)
		@utils = Utils.new(home_dir)
		@home_dir = home_dir
	end

	def fetch(target_dir, target)
		puts "fetching git sources..."
		if File.directory?("#{target_dir}/#{target.module}/.git")
			@utils.error("target version #{target.version} is already installed")
		end

		@utils.command "#{target_dir}",
			    "git clone #{target.repository}",
				"error cloning git repo for target #{target.version}",
				false
	end

	def update(target_dir, target)
		@utils.error("cannot update from tarball source") unless target.is_from_repository?

		if !File.directory?("#{target_dir}/#{target.module}/.git")
			@utils.error("target version #{target.version} is not installed")
		end

		@utils.command "#{target_dir}/#{target.module}",
			    "git reset --hard",
				"error reseting git repo for target #{target.version}",
				false

		@utils.command "#{target_dir}/#{target.module}",
			    "git clean -df",
				"error cleaning git repo for target #{target.version}"

		@utils.command "#{target_dir}/#{target.module}",
			    "git checkout #{target.branch}",
				"error checking out branch #{target.branch}"

		@utils.command"#{target_dir}/#{target.module}",
				'git pull',
				 "error pulling from git repo for target #{target.version}"
	end

	def configure(target)
		puts "configuring..."
		mono_prefix = @utils.get_mono_prefix(target)

		configure_cmd = './autogen.sh'
		@utils.command "#{target.source_dir(@home_dir)}/#{target.module}",
				"#{configure_cmd} --prefix=#{mono_prefix}",
				'failed to configure mono'
	end

	def build(target)
		puts "making #{target.module}..."

		puts "compiling..."
		@utils.command "#{target.source_dir(@home_dir)}/#{target.module}",
				"make",
				'failed to compile mono'

		puts "installing..."
		@utils.command "#{target.source_dir(@home_dir)}/#{target.module}",
				"make install",
				'failed to install mono'
	end
end
