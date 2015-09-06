#!/usr/bin/ruby

require 'pathname'


steamapps_dir = ARGV[0]


def main(steamapps_dir)
	games = Array.new	
	get_acf_files(steamapps_dir || "#{ENV['HOME']}/.steam/steam/SteamApps/").each do |f|
		id, name = nil, nil
		File.open(f).each_line.collect do |line| line.strip end.each do |line|
			if names = line.match(/^"name"[ \t]*"(.*)"$/)
				name = names[1]
			end
			if ids = line.match(/^"appID"[ \t]*"(.*)"$/)
				id = ids[1]
			end
		end
		name.gsub! "&", "&amp;"
		games << [id, name]
	end	
	games.sort_by! do |game| game[0].to_i end

	puts '<openbox_pipe_menu>'
	puts '<item label="Steam"><action name="Execute"><execute>steam</execute></action></item>'
	puts '<separator/>'
	games.each do |game|
		puts "<item label=\"#{game[1]}\"><action name=\"Execute\"><execute>steam steam://run/#{game[0]}</execute></action></item>"
	end
	puts '</openbox_pipe_menu>'
end


def get_acf_files(dir)
	if !dir.nil? and Pathname.new(dir).directory?
		return Pathname.new(dir).children.select do |c| c.file? and c.readable? and not c.symlink? and c.basename.to_s =~ /appmanifest_\d+\.acf/ end
	else
		return []
	end
end


main(steamapps_dir)