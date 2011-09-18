class Target
	attr_accessor :repository,
				  :module,
				  :branch,
				  :tarball_url,
				  :tarball_filename,
				  :tarball_extract_folder,
				  :version,
				  :dependencies,
				  :use_configure

	def initialize(src = :from_tarball)
		@src = src
	end

	def is_tarball?
		return @src == :from_tarball
	end

	def is_from_repository?
		return @src == :from_repository
	end

	def source_dir(home_dir)
		@source_dir || create_source_dir(home_dir)
	end

	private
	def create_source_dir(home_dir)
		src_dir = "#{home_dir}/sources"
		Dir.mkdir(src_dir) if !File.directory?(src_dir)

		target_dir = if @module == 'mono' 
					     "#{src_dir}/#{@version}"
					 else
					     "#{src_dir}/#{@module}_#{@version}"
					 end

		Dir.mkdir(target_dir) if !File.directory?(target_dir)

		@source_dir = target_dir
		target_dir
	end
end

class TargetFetcher
	attr_reader :targets

	GIT_BASE = 'http://github.com/mono'

	def initialize
		@targets = []
		#TODO: this is a great opportunity for meta programming!
		@targets.push create_mono_HEAD_target
		@targets.push create_mono_2_10_HEAD_target
		@targets.push create_mono_2_10_4_target
		@targets.push create_mono_2_10_5_target
		@targets.push create_gtk_sharp_2_12_11_target
	end

	def get_target(mod, version)
		@targets.each {|t| return t if t.version == version and t.module == mod}
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
		target.use_configure = false

		target
	end

	def create_mono_2_10_HEAD_target
		target = Target.new(:from_repository)
		target.module = 'mono'
		target.repository = "#{GIT_BASE}/mono.git"
		target.branch = 'mono-2-10'
		target.version = '2.10-HEAD'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'
		target.use_configure = false

		target
	end

	def create_mono_2_10_4_target
		target = Target.new
		target.module = 'mono'
		target.tarball_url = "http://download.mono-project.com/sources/mono/"
		target.tarball_filename = "mono-2.10.4.tar.bz2"
		target.tarball_extract_folder = "mono-2.10.4"
		target.version = '2.10.4'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'
		target.use_configure = true

		target
	end

	def create_mono_2_10_5_target
		target = Target.new
		target.module = 'mono'
		target.tarball_url = "http://download.mono-project.com/sources/mono/"
		target.tarball_filename = "mono-2.10.5.tar.bz2"
		target.tarball_extract_folder = "mono-2.10.5"
		target.version = '2.10.5'
		target.dependencies = 'automake libtool gawk intltool autoconf automake bison flex git-core gcc gcc-c++'
		target.use_configure = true

		target
	end

	def create_gtk_sharp_2_12_11_target
		target = Target.new
		target.module = 'gtk-sharp'
		target.tarball_url = "http://download.mono-project.com/sources/gtk-sharp212/"
		target.tarball_filename = "gtk-sharp-2.12.11.tar.bz2"
		target.tarball_extract_folder = "gtk-sharp-2.12.11"
		target.version = '2.12.11'
		target.dependencies = 'gtk2-devel'
		target.use_configure = true
		 
		target
	end
end
