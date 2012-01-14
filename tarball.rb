require File.dirname(__FILE__) + '/utils.rb'

class TarballFetcher
	def initialize(home_dir)
		@utils = Utils.new(home_dir)
		@home_dir = home_dir
	end

	def fetch(target_dir, target)
		puts "fetching tarball sources..."
        puts "#{target_dir}/#{target.tarball_filename}"
		if !File.exists?("#{target_dir}/#{target.tarball_filename}")
			@utils.command "#{target_dir}",
					"wget #{target.tarball_url}/#{target.tarball_filename}",
					"error fetching tarball for target #{target.version}",
					true
		end

		if !File.directory?("#{target_dir}/#{target.tarball_extract_folder}")
			@utils.command "#{target_dir}",
					"#{target.tarball_extract_cmd} #{target.tarball_filename}",
					"error unarchiving tarball for target #{target.version}",
					true
		end
	end

	def configure(target)
		puts "configuring..."
		mono_prefix = @utils.get_mono_prefix(target)

		configure_cmd = './configure'
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"#{configure_cmd} --prefix=#{mono_prefix}",
				"failed to configure #{target.module}"
	end

	def build(target)
		puts "making #{target.module}..."

		puts "compiling..."
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"make",
				"failed to compile #{target.module}"

		puts "installing..."
		sudo_cmd = target.install_as_root ? 'sudo' : ''
		@utils.command "#{target.source_dir(@home_dir)}/#{target.tarball_extract_folder}",
				"#{sudo_cmd} make install",
				"failed to install #{target.module}"
	end
end
