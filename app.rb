require File.dirname(__FILE__) + '/targets.rb'
require File.dirname(__FILE__) + '/git.rb'
require File.dirname(__FILE__) + '/command.rb'

class App
	def initialize
		@target_fetcher = TargetFetcher.new
		@command = Command.new(home_dir)
		@git_fetcher = GitFetcher.new(home_dir)

		Dir.mkdir(home_dir) if !File.directory?(home_dir)
	end

	def help
		puts "list options here..."
		exit 1
	end

	def list_known_targets
		puts "available targets:"
		known_targets().each {|target_version| puts target_version}
	end

	def switch(target_version)
		validate_target(target_version)
		target = @target_fetcher.get_target(target_version)

		src_dir = "#{home_dir}/sources"
		target_dir = "#{src_dir}/#{target.version}"

		if !File.exist?("#{target_dir}/mono-environment")
			@command.error "target version #{target_version} is not installed."
		end

		mono_prefix = get_mono_prefix(target)
		gnome_prefix ='/usr'

		ENV['DYLD_LIBRARY_FALLBACK_PATH'] = "#{mono_prefix}/lib:#{ENV['DYLD_LIBRARY_FALLBACK_PATH']}"
		ENV['LD_LIBRARY_PATH'] = "#{mono_prefix}/lib:#{ENV['LD_LIBRARY_PATH']}"
		ENV['C_INCLUDE_PATH'] = "#{mono_prefix}/include:#{gnome_prefix}/include"
		ENV['ACLOCAL_PATH'] = "#{mono_prefix}/share/aclocal"
		ENV['PKG_CONFIG_PATH'] = "#{mono_prefix}/lib/pkgconfig:#{gnome_prefix}/lib/pkgconfig"
		ENV['MOPEM_PATH'] = "#{mono_prefix}/bin"
		ENV['MOPEM_PS1'] = "[mono-#{target.version}] "

		exec '/usr/bin/env bash'
	end

	def rebuild(target_version)
		validate_target(target_version)
		target = @target_fetcher.get_target(target_version)
		target_dir = create_source_dir(target)

		if !File.directory?("#{target_dir}/#{target.module}/.git")
			@command.error("target version #{target_version} is not installed")
		end

		puts "rebuilding..."
		build(target)

		puts "done!"
	end

	def install(target_version)
		validate_target(target_version)
		target = @target_fetcher.get_target(target_version)
		target_dir = create_source_dir(target)

		install_dependencies(target)

		puts "fetching sources..."
		if target.is_from_repository?
			@git_fetcher.fetch(target_dir, target)
		else
			@tarball_fetcher.fetch(target_dir, target)
		end

		configure(target)
		build(target)

		puts "done!"
	end

	def update(target_version)
		validate_target(target_version)
		target = @target_fetcher.get_target(target_version)
		target_dir = create_source_dir(target)

		install_dependencies(target)

		puts "updating..."
		@git_fetcher.update(target_dir, target)
		configure(target)
		build(target)

		puts "done!"
	end

	private
	def install_dependencies(target)
		puts "installing dependencies. This might require you to enter your sudo password"
		if !system "sudo zypper install -y #{target.dependencies}"
			@command.error 'failed to install dependencies'
		end
	end

	def get_mono_prefix(target)
		"#{home_dir}/install/mono-#{target.version}"
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

	def configure(target)
		puts "configuring..."
		mono_prefix = get_mono_prefix(target)
		env_script_cmd = create_environment_script(target)

		configure_cmd = './autogen.sh' if target.is_from_repository?
		configure_cmd = './configure' if target.is_tarball?

		@command.execute "#{target.source_dir}/#{target.module}",
				"#{env_script_cmd} && #{configure_cmd} --prefix=#{mono_prefix}",
				'failed to configure mono'
	end

	def build(target)
		puts "making #{target.module}..."
		env_script_cmd = create_environment_script(target)

		puts "compiling..."
		@command.execute "#{target.source_dir}/#{target.module}",
				"#{env_script_cmd} && make",
				'failed to compile mono'

		puts "installing..."
		@command.execute "#{target.source_dir}/#{target.module}",
				"#{env_script_cmd} && make install",
				'failed to install mono'
	end

	def home_dir
		"#{File.expand_path('~')}/.mopem"
	end

	def validate_target(target_version)
		unless known_targets().include?(target_version)
			@command.error "target version #{target_version} not found"
		end
	end

	def known_targets
		return_val = []
		@target_fetcher.targets.each do |t|
			return_val.push t.version
		end

		return_val
	end

	def create_source_dir(target)
		src_dir = "#{home_dir}/sources"
		Dir.mkdir(src_dir) if !File.directory?(src_dir)

		target_dir = "#{src_dir}/#{target.version}"
		Dir.mkdir(target_dir) if !File.directory?(target_dir)

		target.source_dir = target_dir
		target_dir
	end
end
