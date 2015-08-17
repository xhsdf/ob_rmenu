#!/usr/bin/ruby

require 'pathname'
require 'etc'


# TODO: new group for all applets ?
# TODO: new group for wine/.exe processes ?
# TODO: priority keywords?

def main()
	groups = []
	puts '<openbox_pipe_menu>'
	get_pids().each do |pid|
		process = ProcessInfo.new(pid)
		add_to_group(groups, process)
	end
	
	users = []
	groups.each do |group|
		users << [group.user, group.username]
	end
	users.uniq!.sort!.reverse!
	
	users.each do |user, username|
		puts '<separator label="%s"/>' % username
		groups.each do |group|
			if group.user == user
				group.get_entry()
			end
		end
	end

	
	puts '</openbox_pipe_menu>'
end

def add_to_group(groups, process)
	groups.each do |group|
		if get_short_name(process.name) == group.name
			group.add(process)
			return
		end
	end
	groups << ProcessGroup.new(process)
end

def get_process_entry(process, group = false)
	puts "<menu id=\"process_#{process.pid}\" label=\"#{process.name}#{group ? " (#{process.pid})" : ""}\">"
	puts '<item label="kill process %d"><action name="Execute"><execute>kill %d</execute></action></item>' % [process.pid, process.pid]
	puts '<item label="kill -9 process %d"><action name="Execute"><execute>kill -9 %d</execute></action></item>' % [process.pid, process.pid]
	puts '<item label="open /proc/%d"><action name="Execute"><execute>gnome-open /proc/%d</execute></action></item>' % [process.pid, process.pid]
	puts '</menu>'
end

def get_short_name(name)
	return name[/^[^\/]+/]
end


class ProcessGroup
	attr_reader :processes
	attr_reader :name
	attr_reader :user
	attr_reader :username

	def initialize(process)
		@name = get_short_name(process.name)
		@user = process.user
		@username = process.username
		@processes = []
		self.add(process)
	end
	
	def add(process)
		@processes << process
	end
	
	def get_entry()
		puts @name
		if @processes.length == 1
			get_process_entry(@processes[0])
		else
			puts '<menu id="process_group_%s" label="%s (%d)">' % [@name, @name, @processes.length]
			@processes.each do |process|
				get_process_entry(process, true)			
			end			
			puts '</menu>'
		end
	end
end


class ProcessInfo
	attr_reader :pid
	attr_reader :name
	attr_reader :user
	attr_reader :username
	def initialize(pid)
		@pid = pid
		@name, @user = get_status()
		@username = Etc.getpwuid(@user.to_i).name
	end

	def get_status()
		begin
			status_file = get_status_file()
			name = status_file[/(?<=Name:\t).*?(?=\n)/]
			user = status_file[/(?<=Uid:\t)\d+/].to_i
			return name, user
		rescue
			return '---'
		end
	end

	def get_state()
		begin
			return get_status_file()[/(?<=State:\t)\w/]
		rescue
			return '---'
		end
	end
	
	def get_folder()
		return '/proc/%s/' % @pid
	end
	
	def get_status_file()
		return File.read('%s/status' %  get_folder())
	end
end


def get_pids()
	return Pathname.new('/proc').children.select do |c| c.directory? and c.readable? and not c.symlink? and c.basename.to_s =~ /\d+/ end.collect do |path| path.basename.to_s.to_i end.sort().reverse()
end

main()
