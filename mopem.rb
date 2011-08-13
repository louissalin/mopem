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

	app.fetch(target_version)
end

