class Target
	attr_accessor :repository,
				  :module,
				  :branch,
				  :tarball_url,
				  :tarball_filename,
				  :tarball_extract_folder,
				  :version,
				  :dependencies,
				  :mono_dependencies,
				  :use_configure,
				  :install_as_root

	def initialize(src = :from_tarball)
		@src = src
		@install_as_root = false
		@mono_dependencies = {}
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
		@targets.push create_libgdiplus_2_10_target
		@targets.push create_xsp_2_10_2_target
		@targets.push create_mod_mono_2_10_target
		@targets.push create_mono_addins_0_6_2_target
		@targets.push create_monodevelop_2_8_target
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

	def create_libgdiplus_2_10_target
		target = Target.new
		target.module = 'libgdiplus'
		target.tarball_url = "http://download.mono-project.com/sources/libgdiplus/"
		target.tarball_filename = "libgdiplus-2.10.tar.bz2"
		target.tarball_extract_folder = "libgdiplus-2.10"
		target.version = '2.10'
		target.dependencies = 'freetype2-devel fontconfig-devel libpng14-devel'
		target.use_configure = true
		 
		target
	end

	def create_xsp_2_10_2_target
		target = Target.new
		target.module = 'xsp'
		target.tarball_url = "http://download.mono-project.com/sources/xsp/"
		target.tarball_filename = "xsp-2.10.2.tar.bz2"
		target.tarball_extract_folder = "xsp-2.10.2"
		target.version = '2.10.2'
		target.dependencies = nil
		target.use_configure = true
		 
		target
	end

	def create_mod_mono_2_10_target
		target = Target.new
		target.module = 'mod_mono'
		target.tarball_url = "http://download.mono-project.com/sources/mod_mono/"
		target.tarball_filename = "mod_mono-2.10.tar.bz2"
		target.tarball_extract_folder = "mod_mono-2.10"
		target.version = '2.10'
		target.dependencies = 'apache2-devel'
		target.use_configure = true
		target.install_as_root = true
		 
		target
	end

	def create_mono_addins_0_6_2_target
		target = Target.new
		target.module = 'mono-addins'
		target.tarball_url = "http://download.mono-project.com/sources/mono-addins/"
		target.tarball_filename = "mono-addins-0.6.2.tar.bz2"
		target.tarball_extract_folder = "mono-addins-0.6.2"
		target.version = '0.6.2'
		target.dependencies = nil
		target.use_configure = true
		 
		target
	end

	def create_monodoc_2_0_target
		target = Target.new
		target.module = 'monodoc'
		target.tarball_url = "http://download.mono-project.com/sources/monodoc/"
		target.tarball_filename = "monodoc-2.0.tar.bz2"
		target.tarball_extract_folder = "monodoc-2.0"
		target.version = '2.0'
		target.dependencies = nil
		target.use_configure = true
		 
		target
	end

	def create_monodevelop_2_8_target
		target = Target.new
		target.module = 'monodevelop'
		target.tarball_url = "http://download.mono-project.com/sources/monodevelop/"
		target.tarball_filename = "monodevelop-2.8.tar.bz2"
		target.tarball_extract_folder = "monodevelop-2.8"
		target.version = '2.8'
		target.dependencies = nil
		target.mono_dependencies = {"gtk-sharp" => "2.8.0", 
									"monodoc" => "1.0",
									"gecko-sharp2" => "0.10",
									"gtksourceview-sharp2" => "0.10"}
		target.use_configure = true

		target
	end
end
