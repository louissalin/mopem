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

	def fetch(target_version)
		validate_target(target_version)
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
		@target_fetcher.targets.keys.each do |target_key|
			return_val.push @target_fetcher.targets[target_key].version
		end

		return_val
	end
end
