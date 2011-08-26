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
	utils.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.install(target_version)
	exit 0
end

if (ARGV[0] == 'update')
	utils.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.update(target_version)
	exit 0
end

if (ARGV[0] == 'rebuild')
	utils.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.rebuild(target_version)
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
