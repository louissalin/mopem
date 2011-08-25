class Target
	attr_accessor :repository,
				  :module,
				  :branch,
				  :tarball_url,
				  :version,
				  :source_dir,
				  :dependencies

	def initialize(src = :from_tarball)
		@src = src
	end

	def is_tarball?
		return @src == :from_tarball
	end

	def is_from_repository?
		return @src == :from_repository
	end
end

class TargetFetcher
	attr_reader :targets

	GIT_BASE = 'http://github.com/mono'

	def initialize
		@targets = []
		@targets.push create_mono_HEAD_target
		@targets.push create_mono_2_10_HEAD_target
	end

	def get_target(version)
		@targets.each {|t| return t if t.version == version}
		nil
	end

	private
	def create_mono_HEAD_target
		target = Target.new(:from_repository)
		target.module = 'mono'
		target.repository = "#{GIT_BASE}/mono.git"
		target.branch = 'master'
		target.version = 'master-HEAD'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'

		target
	end

	def create_mono_2_10_HEAD_target
		target = Target.new(:from_repository)
		target.module = 'mono'
		target.repository = "#{GIT_BASE}/mono.git"
		target.branch = 'mono-2-10'
		target.version = '2.10-HEAD'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'

		target
	end

	def create_mono_2_10_2
		target = Target.new
		target.module = 'mono'
		target.tarball_url = "http://ftp.novell.com/pub/mono/sources-stable/mono-2.10.2.tar.bz2"
		target.version = '2.10.2'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'

		target
	end
end
