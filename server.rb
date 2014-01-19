require 'webrick'
require 'thread'
require './server_commands'
class ChatRunner
	class ChatServer < WEBrick::GenericServer

		include ServerCommands

		def username sock
			@usernames ||= []
			Thread.current[:username] = nil
			loop do
				sock.puts "Login name?"
				Thread.current[:username] = sock.gets.strip
				unless @usernames.include? Thread.current[:username]
					@usernames << Thread.current[:username]
					sock.puts "Welcome #{Thread.current[:username]}!"
					break
				else
					sock.puts "Sorry, name taken."
				end
			end
		end

		def shutdown
			super
			puts "\nGoodbye!"
			Thread.list.each(&exit)
		end

		def run(sock)
			sock.puts "Welcome to the XYZ chat server"
			sock.puts "Type /help for help."
			self.username sock

			@threads ||= []
			@threads << user_thread = Thread.new(sock) do |sock|
				Thread.abort_on_exception = true
				loop do
					Thread.stop
					current_room = Thread.current[:current_room]
					if @message[:room] == current_room
						unless @message[:system]
							sock.puts "#{@message[:username]}:\
 #{@message[:message]}"
						else
							sock.puts " * #{@message[:message]}"
						end
					end

				end
			end
			loop do
				@message = {:time => Time.new, 
					:room => user_thread[:current_room], 
					:username => Thread.current[:username],
					:message => sock.gets.to_s.strip}
				if @message[:message].length > 0 && @message[:message][0] == "/"
					self.proccess_command @message[:message][1..-1],
					 user_thread,
					 sock
				else
					@threads.each do |thread|
					 	thread.run if thread.status == "sleep"
					end
				end
			end
		end
	end
	
	def initialize
		
		server = ChatServer.new :Port => (ARGV.first || 80)

		trap('INT') { server.shutdown }


		# begin
			server.start
		# rescue 
		# 	server.shutdown
		# end
	end
	
	
end

ChatRunner.new

