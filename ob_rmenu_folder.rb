#!/usr/bin/ruby

require 'pathname'

def main(args)
	recursive = false
	folder = '/'
	args.each do |arg|
		if arg == '-r'
			recursive = true
		elsif Pathname.new(arg).directory?
			folder = arg
		end
	end

	puts '<openbox_pipe_menu>'
	get_folder_items(folder, recursive, true)
	puts '</openbox_pipe_menu>'
end

def get_folders(dir)
	get_items(dir).select do |item| item.directory? end
end

def get_files(dir)
	get_items(dir).select do |item| item.file? end
end

def get_items(dir)
	return Pathname.new(dir).children.select do |c| c.readable? and not c.symlink? end.sort_by do |c| c.to_s.downcase end
end

def get_item_name(item)
	return to_xml(Pathname.new(item).basename.to_s)
end

def to_xml(string)
	return string.gsub('&', '&amp;').gsub('"', '&quot;')
end

def get_folder_label(item, name, recursive)
	if recursive
		puts '<menu id="%s" label="%s">' % [item, name]
		puts get_item_label(item, 'open')
		get_folder_items(item, recursive)
		puts '</menu>'
	else
		puts  get_item_label(item, name)
	end
end

def get_item_label(item, text)
	return "<item label=\"#{text}\"><action name=\"Execute\"><execute>xdg-open \"#{to_xml(item.to_s)}\"</execute></action></item>"
end

def get_folder_items(dir, recursive, categories = false)
	all_folders = get_folders(dir)
	#puts '<separator label="%s (%d)"/>' % [ get_item_name(dir), all_folders.length]
	if all_folders.length > 50
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars.each do |c|
			folders = all_folders.select do |item| get_item_name(item).start_with?(c, c.downcase) end
			if not folders.empty?
				puts "<menu id=\"#{dir.to_s}-#{c}\" label=\"#{c} (#{folders.length})      \">"
				folders.each do |item|
					name = get_item_name(item)
					if(name.start_with?(c, c.downcase))
						get_folder_label(item, name, recursive)			
					end
				end
				puts '</menu>'
			end
		end	
	else
		all_folders.each do |item|
			name = get_item_name(item)
			get_folder_label(item, name, recursive)	
		end

		get_files(dir).each do |item|
			name = get_item_name(item)
			puts  get_item_label(item, name)
		end
	end
end

main(ARGV)

