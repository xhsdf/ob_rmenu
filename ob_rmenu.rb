#!/usr/bin/ruby

require 'pathname'

def main(menu_file, icon_folder)
	puts '<openbox_pipe_menu>'
	#puts '<separator label="%s"/>' % Time.now.strftime("%Y-%m-%d     %H:%M") # TODO calendar
	#puts '<separator label="%s"/>' % ENV['USER']
	print_menu(File.open(menu_file), get_icons(icon_folder))	
	puts '</openbox_pipe_menu>'
end

def print_menu(lines, icons)
	id = 0
	depth = 0
	lines.each do |line|
		if line.strip.start_with? '#'
			next
		end
		line_depth = line[/^\t*/].size		
		if line_depth < depth
			for i in 1..(depth - line_depth)
				puts '</menu>'
			end
		elsif line_depth > depth
			depth = line_depth
		end
		
		line = line.strip()
		depth = line_depth
		if  line.empty?
			puts '<separator/>'
		elsif line.start_with? 'menu:'
			puts get_menu_entry(line, icons, id)
			id += 1
		else
			puts get_item_entry(line, icons)
		end
	end
	if depth > 0
		for i in 1..(depth)
			puts '</menu>'
		end
	end
end

def get_icons(icon_folder)
	if not icon_folder.nil? and Pathname.new(icon_folder).directory?
		return Pathname.new(icon_folder).children.collect do |file| [file, file.basename.to_s.downcase[/.*(?=\.[^\.]+)/]] end
	else
		return []
	end
end

def get_icon_string(line, icons)
	icons.each do |file, name|
		if line.downcase.start_with? name or (line.start_with?('/', '~') and name == 'places')
			return ' icon="%s"' % file
		end
	end
	return ''
end

def get_item_entry(line, icons)
	if line.start_with? 'action:'
		action = line[line.index(':')+1..-1]
		return '<item%s label="%s"><action name="%s"/></item>' % [get_icon_string(action, icons), action, action]
	else
		name = line[0..line.index('=')-1]
		exec = line[line.index('=')+1..-1]
		exec.gsub!('$menu_folder', File.dirname(__FILE__))
		return '<item%s label="%s"><action name="Execute"><execute>%s</execute></action></item>' % [get_icon_string(name, icons), name, to_xml(exec)]
	end	
end

def get_menu_entry(line, icons, id)
	line = line[line.index(':')+1..-1]
	if line.start_with? 'id:'
		line = line[line.index(':')+1..-1]
		return '<menu%s id="%s"/>' % [get_icon_string(line, icons), line]
	elsif line.start_with? 'exec:'
		line = line[line.index(':')+1..-1]
		name = line[0..line.index('=')-1]
		exec = line[line.index('=')+1..-1]
		exec.gsub!('$menu_folder', File.dirname(__FILE__))
		return '<menu%s id="xh_%s-%d" label="%s" execute="%s"/>' % [get_icon_string(name, icons), name, id, name, exec]
	else
		return '<menu%s id="xh_%s-%d" label="%s">' % [get_icon_string(line, icons), line, id, line]
	end
end

def to_xml(string)
	return string.gsub('&', '&amp;').gsub('"', '&quot;')
end

main(ARGV[0], ARGV[1])
