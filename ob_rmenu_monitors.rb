#!/usr/bin/ruby


def main()
	xrandr_output = `xrandr --query`

	displays = []
	xrandr_output.each_line do |line|
		if line =~ /[A-Za-z]-?\d+ connected/
			displays << line.split(" ")[0]
		end
	end

	puts '<openbox_pipe_menu>'
	puts "<separator label=\"[x]\"/>"
	displays.each do |display1|
			other_displays = displays.reject do |display| display == display1 end
			deactivate_string = other_displays.collect do |display| ";xrandr --output #{display} --off " end.join
			puts "<item label=\"[#{display1}]\"><action name=\"Execute\"><execute> sh -c 'xrandr --output #{display1} --auto --pos 0x0 #{deactivate_string}'</execute></action></item>"
	end
	puts "<separator label=\"[x+y]\"/>"
	displays.each_with_index do |display1, i|
		displays.each_with_index do |display2, u|
			other_displays = displays.reject do |display| display == display1 or display == display2 end
			unless display1 == display2 or u < i
				deactivate_string = other_displays.collect do |display| ";xrandr --output #{display} --off " end.join
				puts "<item label=\"[#{display1}+#{display2}]\"><action name=\"Execute\"><execute> sh -c 'xrandr --output #{display1} --auto --pos 0x0 #{deactivate_string}; xrandr --output #{display2} --auto --pos 0x0'</execute></action></item>"
			end
		end
	end
	puts "<separator label=\"[x][y]\"/>"
	displays.each do |display1|
		displays.each do |display2|
			other_displays = displays.reject do |display| display == display1 or display == display2 end
			unless display1 == display2
				deactivate_string = other_displays.collect do |display| ";xrandr --output #{display} --off " end.join
				puts "<item label=\"[#{display1}][#{display2}]\"><action name=\"Execute\"><execute> sh -c 'xrandr --output #{display1} --auto --pos 0x0 #{deactivate_string}; xrandr --output #{display2} --auto --right-of #{display1}'</execute></action></item>"
			end
		end
	end
	puts '</openbox_pipe_menu>'
end

main()