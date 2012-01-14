require 'rubygems'
require 'yaml'

class Target
	attr_accessor :repository,
				  :module,
				  :branch,
				  :tarball_url,
				  :tarball_filename,
				  :tarball_extract_folder,
                  :tarball_extract_cmd,
				  :version,
				  :dependencies,
				  :mono_dependencies,
				  :use_configure,
				  :install_as_root,
				  :source_dir

	def initialize
		@install_as_root = false
		@mono_dependencies = []
	end

	def is_tarball?
		return @tarball_url != nil
	end

	def is_from_repository?
		return @repository != nil
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

class MonoDependency
    attr_reader :name,
                :version,
                :error

    def initialize(name, version, error)
        @name = name
        @version = version
        @error = error
    end
end

class TargetFetcher
	attr_reader :targets

	GIT_BASE = 'git://github.com/mono'

	def initialize
		@utils = Utils.new
		@targets = []

		yml = YAML.parse_file(File.dirname(__FILE__) + '/targets.yml')
		yml_targets = yml.select('/target/*')
		yml_targets.each do |t|
			@targets.push create_target(t.transform)
		end
	end

	def get_target(mod, version)
		@targets.each {|t| return t if t.version.to_s == version and t.module == mod}
		nil
	end

	private
	def create_target(yml_target)
		source = yml_target['source']

		target = Target.new
		target.module = yml_target['module']
		target.version = yml_target['version'].to_s
		target.install_as_root = yml_target['install_as_root']
		
		sys_dep = yml_target['system_dependencies']

		if @utils.is_zypper_available then
			target.dependencies = sys_dep['zypper']
		elsif @utils.is_apt_get_available then
			target.dependencies = sys_dep['apt_get']
		end
		
		from_git_repo = source['git_repository'] != nil
		if from_git_repo then
			target.repository = "#{GIT_BASE}/#{source['git_repository']}"
			target.branch = yml_target['branch']
			target.use_configure = false
		else
			target.tarball_url = source['tarball_url']
			target.tarball_filename = source['tarball_filename']
			target.tarball_extract_folder = get_extract_folder_from_filename(target.tarball_filename)
			target.tarball_extract_cmd = get_extract_command(target.tarball_filename)
			target.use_configure = true
		end

        dependencies = yml_target['mono_dependencies']
        if dependencies != nil
            dependencies.each do |dep|
                target.mono_dependencies << MonoDependency.new(dep['name'], 
                                                               dep['version'].to_s, 
                                                               dep['error'])
            end
        end

		target
	end

	def get_extract_folder_from_filename(filename)
		if filename =~ /.tar.bz2$/
			return filename[0..filename.length - 9]
		end

		if filename =~ /.tar.gz$/
			return filename[0..filename.length - 8]
		end

		''
	end

    def get_extract_command(filename)
		if filename =~ /.tar.bz2$/
			return 'tar xvjf'
		end

		if filename =~ /.tar.gz$/
			return 'tar xvzf'
		end

		''
    end
end
