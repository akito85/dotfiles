# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_juliaup_global_optspecs
	string join \n h/help V/version
end

function __fish_juliaup_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_juliaup_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_juliaup_using_subcommand
	set -l cmd (__fish_juliaup_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c juliaup -n "__fish_juliaup_needs_command" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_needs_command" -s V -l version -d 'Print version'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "default" -d 'Set the default Julia version'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "add" -d 'Add a specific Julia version or channel to your system. Access via `julia +{channel}` e.g. `julia +1.6`'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "link" -d 'Link an existing Julia binary to a custom channel name'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "list" -d 'List all available channels'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "override" -d 'Manage directory overrides'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "update" -d 'Update all or a specific channel to the latest Julia version'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "remove" -d 'Remove a Julia version from your system'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "status" -d 'Show all installed Julia versions'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "gc" -d 'Garbage collect uninstalled Julia versions'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "config" -d 'Juliaup configuration'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "api"
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "46029ef5-0b73-4a71-bff3-d0d05de42aac"
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf"
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "info"
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "self" -d 'Manage this juliaup installation'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "completions" -d 'Generate tab-completion scripts for your shell'
complete -c juliaup -n "__fish_juliaup_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand default" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand add" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand link" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand list" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and not __fish_seen_subcommand_from status set unset help" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and not __fish_seen_subcommand_from status set unset help" -f -a "status"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and not __fish_seen_subcommand_from status set unset help" -f -a "set"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and not __fish_seen_subcommand_from status set unset help" -f -a "unset"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and not __fish_seen_subcommand_from status set unset help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from set" -s p -l path -r
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from set" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from unset" -s p -l path -r
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from unset" -s n -l nonexistent
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from unset" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from help" -f -a "status"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from help" -f -a "set"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from help" -f -a "unset"
complete -c juliaup -n "__fish_juliaup_using_subcommand override; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand update" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand remove" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand status" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand gc" -l prune-linked
complete -c juliaup -n "__fish_juliaup_using_subcommand gc" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and not __fish_seen_subcommand_from channelsymlinks versionsdbupdateinterval help" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and not __fish_seen_subcommand_from channelsymlinks versionsdbupdateinterval help" -f -a "channelsymlinks" -d 'Create a separate symlink per channel'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and not __fish_seen_subcommand_from channelsymlinks versionsdbupdateinterval help" -f -a "versionsdbupdateinterval" -d 'The time between automatic updates of the versions database in minutes, use 0 to disable'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and not __fish_seen_subcommand_from channelsymlinks versionsdbupdateinterval help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and __fish_seen_subcommand_from channelsymlinks" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and __fish_seen_subcommand_from versionsdbupdateinterval" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "channelsymlinks" -d 'Create a separate symlink per channel'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "versionsdbupdateinterval" -d 'The time between automatic updates of the versions database in minutes, use 0 to disable'
complete -c juliaup -n "__fish_juliaup_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand api" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand 46029ef5-0b73-4a71-bff3-d0d05de42aac" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand info" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and not __fish_seen_subcommand_from update uninstall help" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and not __fish_seen_subcommand_from update uninstall help" -f -a "update" -d 'Update the Julia versions database'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and not __fish_seen_subcommand_from update uninstall help" -f -a "uninstall" -d 'Uninstall this version of juliaup from the system (UNAVAILABLE)'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and not __fish_seen_subcommand_from update uninstall help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and __fish_seen_subcommand_from update" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and __fish_seen_subcommand_from help" -f -a "update" -d 'Update the Julia versions database'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and __fish_seen_subcommand_from help" -f -a "uninstall" -d 'Uninstall this version of juliaup from the system (UNAVAILABLE)'
complete -c juliaup -n "__fish_juliaup_using_subcommand self; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand completions" -s h -l help -d 'Print help'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "default" -d 'Set the default Julia version'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "add" -d 'Add a specific Julia version or channel to your system. Access via `julia +{channel}` e.g. `julia +1.6`'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "link" -d 'Link an existing Julia binary to a custom channel name'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "list" -d 'List all available channels'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "override" -d 'Manage directory overrides'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "update" -d 'Update all or a specific channel to the latest Julia version'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "remove" -d 'Remove a Julia version from your system'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "status" -d 'Show all installed Julia versions'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "gc" -d 'Garbage collect uninstalled Julia versions'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "config" -d 'Juliaup configuration'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "api"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "46029ef5-0b73-4a71-bff3-d0d05de42aac"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "info"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "self" -d 'Manage this juliaup installation'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "completions" -d 'Generate tab-completion scripts for your shell'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and not __fish_seen_subcommand_from default add link list override update remove status gc config api 46029ef5-0b73-4a71-bff3-d0d05de42aac 0cf1528f-0b15-46b1-9ac9-e5bf5ccccbcf info self completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from override" -f -a "status"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from override" -f -a "set"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from override" -f -a "unset"
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "channelsymlinks" -d 'Create a separate symlink per channel'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "versionsdbupdateinterval" -d 'The time between automatic updates of the versions database in minutes, use 0 to disable'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from self" -f -a "update" -d 'Update the Julia versions database'
complete -c juliaup -n "__fish_juliaup_using_subcommand help; and __fish_seen_subcommand_from self" -f -a "uninstall" -d 'Uninstall this version of juliaup from the system (UNAVAILABLE)'
