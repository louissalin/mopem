require File.dirname(__FILE__) + '/targets.rb'

class App
	def initialize
		@target_fetcher = TargetFetcher.new
		Dir.mkdir(home_dir) if !File.directory?(home_dir)
	end

	def help
		puts "list options here..."
		exit 1
	end

	def error(msg)
		puts 'error: ' + msg
		exit 1
	end

	def list_known_targets
		puts "available targets:"
		known_targets().each {|target_version| puts target_version}
	end

	def install(target_version)
		validate_target(target_version)

		target = @target_fetcher.get_target(target_version)
		target_dir = create_source_dir(target)

		if File.directory?("#{target_dir}/#{target.module}/.git")
			error("target version #{target_version} is already installed")
		end

		puts "installing..."
		if !system("cd #{target_dir} && git clone #{target.repository} 1>#{home_dir}/install.log 2>#{home_dir}/error.log")
			error "error cloning git repo for target #{target_version}. Please check #{home_dir}/error.log for details"
		end
	end

	def update(target_version)
		validate_target(target_version)

		target = @target_fetcher.get_target(target_version)
		target_dir = create_source_dir(target)

		if !File.directory?("#{target_dir}/#{target.module}/.git")
			error("target version #{target_version} is not installed")
		end

		puts "updating..."
		if !system("cd #{target_dir}/#{target.module} && git reset --hard 1>#{home_dir}/install.log 2>#{home_dir}/error.log")
			error "error reseting git repo for target #{target_version}. Please check #{home_dir}/error.log for details"
		end

		if !system("cd #{target_dir}/#{target.module} && git clean -df 1>#{home_dir}/install.log 2>#{home_dir}/error.log")
			error "error cleaning git repo for target #{target_version}. Please check #{home_dir}/error.log for details"
		end

		if !system("cd #{target_dir}/#{target.module} && git checkout #{target.branch} 1>#{home_dir}/install.log 2>#{home_dir}/error.log")
			error "error checking out branch #{target.branch}. Please check #{home_dir}/error.log for details"
		end

		if !system("cd #{target_dir}/#{target.module} && git pull 1>#{home_dir}/install.log 2>#{home_dir}/error.log")
			error "error pulling from git repo for target #{target_version}. Please check #{home_dir}/error.log for details"
		end
	end

	private
	def home_dir
		"#{File.expand_path('~')}/.mopem"
	end

	def validate_target(target_version)
		unless known_targets().include?(target_version)
			error "target version #{target_version} not found"
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

		target_dir
	end
end
