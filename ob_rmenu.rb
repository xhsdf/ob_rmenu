#!/usr/bin/ruby

require 'pathname'

$menu_id = 0


def main(menu_file, icon_folder)
	puts '<openbox_pipe_menu>'
	print_menu(RMenu::get_menu(menu_file), get_icons(icon_folder))	
	puts '</openbox_pipe_menu>'
end


def print_menu(menu, icons)
	menu.entries.each do |e|
		$menu_id += 1
		if e.instance_of? RMenu::Menu
			puts '<menu%s id="%d" label="%s">' % [get_icon_string(e.name, icons), $menu_id, e.name.strip]
			print_menu(e, icons)
			puts '</menu>'
		elsif e.instance_of? RMenu::Entry
			name = e.value[/.*?(?=(?<!\\)=)/]
			exec = e.value[/(?<=(?<!\\)=).*/]
			exec.gsub!('$menu_folder', File.dirname(__FILE__)) unless exec.nil?
			action = 'Execute'
			if e.value.start_with? 'exec:'
				name = name.gsub('exec:', '')
				puts '<menu%s id="%d" label="%s" execute="%s"/>' % [get_icon_string(name, icons), $menu_id, name, exec]
			else	
				if e.value.start_with? 'action:'
					action = e.value.gsub(/^action:/, '')
					name = action
				end
				puts '<item%s label="%s"><action name="%s">%s</action></item>' % [get_icon_string(name, icons), name, action, (exec.nil? ? "" : "<execute>#{to_xml(exec)}</execute>")]
			end
		elsif e.instance_of? RMenu::Separator
			puts '<separator/>'
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


def to_xml(string)
	return string.gsub('&', '&amp;').gsub('"', '&quot;')
end


module RMenu
	class Separator
	end

	class Entry
		attr_reader :value
		
		def initialize(value)
			@value = value
		end
	end

	class Menu
		attr_reader :name, :entries
		
		def initialize(name)
			@name, @entries = name, []
		end
		
		def add(entry)
			@entries << entry
		end
	end
		
	def self.get_menu(menu_file)
		menus = Array.new
		root = Menu.new('root')
		menus[0] = root
		File.open(menu_file).each_line.reject do |line| line.lstrip.start_with?('#') end.each do |line|
			level = line.index(/[^\t ]/)
			line.lstrip!
			line.gsub!("\n", '')
			if line.empty?
				menus[level].add(Separator.new)
			elsif line.start_with?('menu:')
				menus[level + 1] = Menu.new(line.sub(/^menu:/, ''))
				menus[level].add(menus[level + 1])
			else
				menus[level].add(Entry.new(line))
			end
		end
		return root
	end
end


main(ARGV[0], ARGV[1])
