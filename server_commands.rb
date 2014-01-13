module ServerCommands

	def proccess_command message, user_thread, sock
		command = message.strip.split(/ /,2)
		command[0] = command.first.downcase

		puts "Command logged: #{command.join " "}"

		if ["quit", "rooms", "join", "leave", "users"].
			include? command.first
			self.send *command, user_thread, sock
		else
			sock.puts "Not a valid command."
		end
	end

	def quit *arg, user_thread, sock
			self.leave user_thread, sock
			sock.puts "BYE"
			Thread.kill(Thread.current)
	end

	def rooms *arg, user_thread, sock
		@rooms ||= Hash.new([])
		sock.puts "Active rooms are:"
		@rooms.each do |name, users|
			sock.puts " * #{name} (#{users.length})"
		end
		sock.puts "end of list."
	end

	def join  *args, room_name, user_thread, sock
		if room_name.to_s.length > 0
			@rooms ||= Hash.new
			@rooms[room_name] ||= []
			@rooms[room_name] << Thread.current[:username]
			user_thread[:current_room] = room_name
		end

		sock.puts "entering room: #{room_name}"
		users room_name, user_thread, sock
	end

	def users *room_name, user_thread, sock
		room_name = room_name.first
		room_name ||= user_thread[:current_room]
		if room_name
			@rooms[room_name].each do |user|
				sock.puts " * #{user}\
#{" (** this is you)" if user == Thread.current[:username]}"
			end
			sock.puts "end of list."
		else
			sock.puts "Not in any room."
		end
	end

	def leave *arg, user_thread, sock
		current_room = user_thread[:current_room]
		if @rooms && current_room
			@rooms[current_room].delete Thread.current[:username]
			@rooms.delete current_room if @rooms[current_room].empty?
			user_thread[:current_room] = nil
		else
			sock.puts "No room to leave."
		end
	end
end