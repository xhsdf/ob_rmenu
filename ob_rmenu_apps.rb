#!/usr/bin/ruby

# xh_openbox_appmenu v0.90

require 'pathname'

CAT_ICON_THEME = 'Mint-X'
ICON_THEMES = ['Mint-X', 'gnome', 'gnome-colors-common', 'hicolor']

def main()
	top_categories = [
	['Graphics', ['2dgraphics', 'graphics', 'photography', 'rastergraphics', 'scanning', 'vectorgraphics']],
	['Accessories', ['archiving', 'calculator', 'compression', 'dictionary', 'texteditor', 'utility', 'discburning', 'terminalemulator', 'office']],
	['Internet', ['email', 'network', 'p2p', 'webbrowser', 'instantmessaging']],
	['Multimedia', ['tv', 'video', 'audio', 'audiovideo', 'music', 'player']],
	['Settings', ['settings', 'hardwaresettings']],
	['System', ['system', 'monitor']]
	]	
	
	icons = get_icons_from_list(ICON_THEMES)	
	icons.concat(get_icons('/usr/share/pixmaps'))
	
	cat_icons = get_icons("/usr/share/icons/#{CAT_ICON_THEME}/categories/16")

	puts '<openbox_pipe_menu>'
	applications = []
	get_application_files().each do |file|
		applications << App.new(file, icons)
	end
	
	applications.sort_by! do |app| app.name.downcase end
	
	top_categories.each do |top_cat, sub_cats|
		done = []
		puts '<menu%s id="top_%s" label="%s">' % [get_cat_icon_string(top_cat, cat_icons), top_cat, top_cat]
		applications.each do |app|
			if category?(sub_cats, app)
				if not done.include? app.exec
					done << app.exec
					puts app.get_entry()
				end
			end
		end
		puts '</menu>'
	end

	puts '<menu%s id="top_cat_etc" label="Etc.">' % get_cat_icon_string('other', cat_icons)
	get_categories(top_categories, applications).each do |cat|
		if unknown_cat?(top_categories, cat)
			puts '<menu id="%s" label="%s">' % [cat, cat]
			get_applications(cat, applications).each do |app|
				puts app.get_entry()
			end
			puts '</menu>'
		end
	end
	puts '</menu>'

	puts '</openbox_pipe_menu>'
end


class App
	attr_reader :name
	attr_reader :exec
	attr_reader :categories
	attr_reader :icon
	
	
	def initialize(file, icons)
		@name, @exec, @categories, @icon_name = get_info(file)
		@icon = get_icon(icons)
	end
	
	def get_entry()
		return '<item%s label="%s"><action name="Execute"><execute>%s</execute></action></item>' % [get_icon_string(), @name, @exec]
	end
	
	def get_icon(icons)
		icons.each do |file, name|
			if @icon_name != nil and @icon_name.downcase == name
				return file
			end
		end
		return nil
	end
	
	def get_icon_string()
		if @icon != nil
			return ' icon="%s"' % @icon
		else
			return ''
		end
	end

	def get_info(file)
		exec = nil
		name = nil
		categories = []
		icon_name = nil
		File.open(file).each do |line|
			if exec == nil and line.start_with?('Exec=', 'exec=')
				exec = get_value(line).gsub(/ ?%[uUfF]/, '').gsub(/ --?[^ ]+/, '')
			elsif name == nil and line.start_with?('Name=', 'name=')
				name = get_value(line)
			elsif categories.empty? and line.start_with?('Categories=', 'categories=')
				categories.concat(get_value(line).downcase.split(';'))
			elsif icon_name == nil and line.start_with?('Icon=', 'icon=')
				icon_name = get_value(line)
			end
		end
		if categories.empty?
			categories << 'Unknown'
		end
		if exec != nil
		
		end
		return name, exec, categories, icon_name
	end

	def get_value(line)
		return line.split('=')[1].gsub("\n", '').chomp()
	end
end

def unknown_cat?(top_categories, cat)
	top_categories.each do |top_cat, sub_cats|
		sub_cats.each do |sub_cat|
			if cat == sub_cat
				return false
			end
		end
	end
	return true
end

def get_icons(icon_folder)
	if Pathname.new(icon_folder).directory?
		return Pathname.new(icon_folder).children.collect do |file| [file, file.basename.to_s.downcase[/.*(?=\.[^\.]+)/]] end.select do |file, name| file.to_s.end_with? '.png' end
	else
		return []
	end
end

def get_icons_from_list(themes)
	icons = []
	themes.each do |theme|
		['apps', 'devices', 'places', 'actions', 'categories'].each do |cat|
			base = '/usr/share/icons/%s' % theme
			['16', '16x16'].each do |pixels|
				icons.concat(get_icons('%s/%s/%s' % [base, cat, pixels]))
				icons.concat(get_icons('%s/%s/%s' % [base, pixels, cat]))
			end
		end
	end
	return icons
end
	
def get_cat_icon_string(cat, icons)
	icons.each do |file, name|
		if name.include? cat.downcase
			return ' icon="%s"' % file
		end
	end
	return ''
end

def category?(categories, app)
	app.categories.each do |cat|
		if categories.include? cat
			return true
		end
	end
	return false
end

	
def get_categories(top_categories, applications)
	categories = []
	applications.each do |app|
		app.categories.each do |cat|
			if not categories.include? cat
				categories << cat
			end
		end
	end
	
	top_categories.each do |top_cat, sub_cats|
		sub_cats.each do |sub_cat|
			categories.delete(sub_cat)
		end
	end
	
	return categories.sort()
end

def get_applications(category, applications)
	cat_applications = []
	applications.each do |app|
		if app.categories.include?(category)
			cat_applications << app
		end
	end
	return cat_applications
end
	
def get_application_files()
	if Pathname.new('/usr/share/applications').directory?
		return Pathname.new('/usr/share/applications').children.select do |c| c.readable? and not c.symlink? and c.to_s.end_with?('.desktop') end.sort()
	else
		return []
	end
end

main()

