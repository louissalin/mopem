require File.dirname(__FILE__) + '/app.rb'
require File.dirname(__FILE__) + '/utils.rb'

app = App.new
utils = Utils.new
app.help if (ARGV.length == 0)

if (ARGV[0] == 'list')
	app.list_known_targets
	exit 0;
end

if (ARGV[0] == 'install')
	utils.error('please specify a module (mono, gtk-sharp, monodevelop, etc...)') if (ARGV.length < 2)
	utils.error('please specify a version') if (ARGV.length < 3)
	mod = ARGV[1]
	target_version = ARGV[2]

	source_folder = nil 
	if ARGV[3] != nil && ARGV[3][0..5] == '--src='
		source_folder = ARGV[3][6..ARGV[3].length]
		puts "using source folder #{source_folder}"
	end

	app.install(mod, target_version, source_folder)
	exit 0
end

if (ARGV[0] == 'update')
	utils.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.update(target_version)
	exit 0
end

if (ARGV[0] == 'use')
	utils.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.switch(target_version)
	exit 0
end

utils.error 'unkown command'
exit 1
