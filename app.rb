require File.dirname(__FILE__) + '/targets.rb'
require File.dirname(__FILE__) + '/git.rb'
require File.dirname(__FILE__) + '/tarball.rb'
require File.dirname(__FILE__) + '/utils.rb'

class App
	def initialize
		@target_fetcher = TargetFetcher.new
		@utils = Utils.new(home_dir)
		@git_fetcher = GitFetcher.new(home_dir)
		@tarball_fetcher = TarballFetcher.new(home_dir)

		Dir.mkdir(home_dir) if !File.directory?(home_dir)
	end

	def help
		puts "list options here..."
		exit 1
	end

	def list_known_targets
		puts "available targets:"
		@target_fetcher.targets.each do |t|
			puts "#{t.module}, version #{t.version}"
		end
	end

	def switch(target_version)
		validate_target('mono', target_version)
		target = @target_fetcher.get_target('mono', target_version)

		src_dir = "#{home_dir}/sources"
		target_dir = "#{src_dir}/#{target.version}"

		if !File.exist?("#{target_dir}/mono-environment")
			@utils.error "target version #{target_version} is not installed."
		end

		mono_prefix = @utils.get_mono_prefix(target)
		gnome_prefix ='/usr'

		ENV['DYLD_LIBRARY_FALLBACK_PATH'] = "#{mono_prefix}/lib:#{ENV['DYLD_LIBRARY_FALLBACK_PATH']}"
		ENV['LD_LIBRARY_PATH'] = "#{mono_prefix}/lib:#{ENV['LD_LIBRARY_PATH']}"
		ENV['C_INCLUDE_PATH'] = "#{mono_prefix}/include:#{gnome_prefix}/include"
		ENV['ACLOCAL_PATH'] = "#{mono_prefix}/share/aclocal"
		ENV['PKG_CONFIG_PATH'] = "#{mono_prefix}/lib/pkgconfig:#{gnome_prefix}/lib/pkgconfig"
		ENV['MOPEM_PATH'] = "#{mono_prefix}/bin"
		ENV['MOPEM_PS1'] = "[mono-#{target.version}] "
		ENV['MOPEM_CURRENT_MONO_VERSION'] = "#{target.version}"

		exec '/usr/bin/env bash'
	end

	def install(mod, target_version)
		validate_target(mod, target_version)
		target = @target_fetcher.get_target(mod, target_version)

		install_dependencies(target)

		puts "fetching sources..."
		if target.is_from_repository?
			@git_fetcher.fetch(target.source_dir(home_dir), target)
			@git_fetcher.configure(target)
			@git_fetcher.build(target)
		else
			@tarball_fetcher.fetch(target.source_dir(home_dir), target)
			@tarball_fetcher.configure(target)
			@tarball_fetcher.build(target)
		end

		puts "done!"
	end

	def update(target_version)
		validate_target(target_version)
		target = @target_fetcher.get_target(target_version)

		if is_tarball?
			@utils.error 'cannot update a tarball install. This works only for HEAD versions' 
		end

		install_dependencies(target)

		puts "updating..."
		@git_fetcher.update(target.source_dir(home_dir), target)
		configure(target)
		build(target)

		puts "done!"
	end

	private
	def install_dependencies(target)
		puts "installing dependencies. This might require you to enter your sudo password"
		if !system "sudo zypper install -y #{target.dependencies}"
			@utils.error 'failed to install dependencies'
		end
	end

	def home_dir
		"#{File.expand_path('~')}/.mopem"
	end

	def validate_target(mod, target_version)
		@target_fetcher.targets.each do |t|
			return if t.version == target_version and t.module == mod
		end

		@utils.error "couldn't find #{mod} version #{target_version}"
	end
end
