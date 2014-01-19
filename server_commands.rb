module ServerCommands

	THE_COMMANDS = ["quit", "rooms", "join", "leave", "users"]

	def proccess_command message, user_thread, sock
		command = message.to_s.strip.split(/ /,2)
		command[0] = command.first.to_s.downcase

		puts "Command logged: #{command.join " "}"


		if THE_COMMANDS.include? command.first
			begin
				self.send *command, user_thread, sock
			rescue ArgumentError => e
				sock.puts "Needs something after that command."
			end
		elsif command.first == "help"
			THE_COMMANDS.each do |command|
				sock.puts "/#{command}"
			end
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
		if @rooms && @rooms.length > 0
			sock.puts "Active rooms are:"
			@rooms.each do |name, users|
				sock.puts " * #{name} (#{users.length})"
			end
			sock.puts "end of list."
		else
			sock.puts "No active rooms."
		end
	end

	def join  *args, room_name, user_thread, sock
		if room_name.to_s.length > 0 && !user_thread[:current_room]
			@rooms ||= Hash.new
			@rooms[room_name] ||= []
			@rooms[room_name] << Thread.current[:username]
			user_thread[:current_room] = room_name

			sock.puts "entering room: #{room_name}"
			users room_name, user_thread, sock

			system_message \
			"new user joined chat: #{Thread.current[:username]}", 
			room_name, user_thread
		elsif user_thread[:current_room]
			sock.puts "You must leave your current room first!"
		else
			sock.puts "You must enter a room name."
		end
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
			system_message \
			"user has left chat: #{Thread.current[:username]}",
			user_thread[:current_room], user_thread
			
			sock.puts "user has left chat: \
#{Thread.current[:username]} (** this is you)"

			@rooms[current_room].delete Thread.current[:username]
			@rooms.delete current_room if @rooms[current_room].empty?
			user_thread[:current_room] = nil
		else
			sock.puts "No room to leave."
		end
	end

	private

	def system_message msg, room_name, user_thread
		@message = {:system => true, :message => msg, :room => room_name}
		(@threads - [user_thread]).each do |thread|
			thread.run if thread.status == "sleep"
		end
	end
end