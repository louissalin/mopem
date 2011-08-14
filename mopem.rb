require File.dirname(__FILE__) + '/app.rb'

app = App.new
app.help if (ARGV.length == 0)

if (ARGV[0] == 'list')
	app.list_known_targets
	exit 0;
end

if (ARGV[0] == 'install')
	app.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.install(target_version)
	exit 0
end

if (ARGV[0] == 'update')
	app.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.update(target_version)
	exit 0
end

if (ARGV[0] == 'rebuild')
	app.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.rebuild(target_version)
	exit 0
end

if (ARGV[0] == 'use')
	app.error('please specify a target') if (ARGV.length < 2)
	target_version = ARGV[1]

	app.switch(target_version)
	exit 0
end

app.error 'unkown command'
exit 1
