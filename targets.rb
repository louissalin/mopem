class Target
	attr_accessor :repository,
				  :tarball_url,
				  :version

	def initialize(src = :from_tarball)
		@src = src
	end
end

class TargetFetcher
	attr_reader :targets

	GIT_BASE = 'http://github.com/mono'

	def initialize
		@targets = Hash.new
		@targets[:HEAD_master] = create_mono_HEAD_target
		@targets[:HEAD_2_10] = create_mono_2_10_HEAD_target
	end

	def get_target(version)

	end

	private
	def create_mono_HEAD_target
		target = Target.new(:from_repository)
		target.repository = "#{GIT_BASE}/mono.git"
		target.version = 'master-HEAD'

		target
	end

	def create_mono_2_10_HEAD_target
		target = Target.new(:from_repository)
		target.repository = "#{GIT_BASE}/mono.git"
		target.version = '2.10-HEAD'

		target
	end
end
