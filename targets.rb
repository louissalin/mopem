require 'rubygems'
require 'yaml'

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

		yml = YAML.parse_file('targets.yml')
		yml_targets = yml.select('/target/*')
		yml_targets.each do |t|
			@targets.push create_target(t.transform)
		end
	end

	def get_target(mod, version)
		@targets.each {|t| return t if t.version == version and t.module == mod}
		nil
	end

	private
	def create_target(yml_target)
		source = yml_target['source']
		from_git_repo = source['git_repository'] != nil

		target = Target.new(from_git_repo)
		target.module = yml_target['module']
		target.version = yml_target['version']
		target.install_as_root = yml_target['install_as_root']
		
		sys_dep = yml_target['system_dependencies']
		target.dependencies = sys_dep['zypper'] || sys_dep['apt_get']
		
		if from_git_repo then
			target.repository = "#{GIT_BASE}/#{source['git_repository']}"
			target.branch = yml_target['branch']
			target.use_configure = false
		else
			target.tarball_url = source['tarball_url']
			target.tarball_filename = source['tarball_filename']
			target.tarball_extract_folder = get_extract_folder_from_filename(target.tarball_filename)
			target.use_configure = true
		end

		target
	end

	def get_extract_folder_from_filename(filename)
		if filename =~ /.tar.bz2$/
			return filename[0..filename.length - 9]
		end

		''
	end

end
