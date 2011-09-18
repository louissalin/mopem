require File.dirname(__FILE__) + '/utils.rb'

class TarballFetcher
	def initialize(home_dir)
		@utils = Utils.new(home_dir)
		@home_dir = home_dir
	end

	def fetch(target_dir, target)
		if File.directory?("#{target_dir}/#{target.module}")
			@utils.error("target version #{target.version} is already installed")
		end

		if !File.exists?("#{target_dir}/#{target.tarball_filename}")
			@utils.command "#{target_dir}",
					"wget #{target.tarball_url}/#{target.tarball_filename}",
					"error fetching tarball for target #{target.version}",
					true
		end

		if !File.directory?("#{target_dir}/#{target.tarball_extract_folder}")
			@utils.command "#{target_dir}",
					"tar xvjf #{target.tarball_filename}",
					"error unarchiving tarball for target #{target.version}",
					true
		end
	end

	def configure(target)
		puts "configuring..."
		mono_prefix = @utils.get_mono_prefix(target)
		env_script_cmd = @utils.get_or_create_envirnment_script(target)

		configure_cmd = './configure'
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"#{env_script_cmd} && #{configure_cmd} --prefix=#{mono_prefix}",
				"failed to configure #{target.module}"
	end

	def build(target)
		puts "making #{target.module}..."

		env_script_cmd = @utils.get_or_create_envirnment_script(target)

		puts "compiling..."
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"#{env_script_cmd} && make",
				"failed to compile #{target.module}"

		puts "installing..."
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"#{env_script_cmd} && make install",
				"failed to install #{target.module}"
	end
end
