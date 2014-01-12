require 'webrick'
require 'thread'

class ChatRunner
	class ChatServer < WEBrick::GenericServer

		def proccess_command message, sock

			command = message.split(/ /,2)
			command[0] = command.first.downcase.strip

			puts "Command logged: #{command.join " "}"

			if ["quit"].include? command.first
				self.send *command, sock
			else
				sock.puts "Not a valid command."
			end
		end

		def quit *args, sock
				sock.puts "BYE"
				Thread.kill(Thread.current)
		end

		def run(sock)
			sock.puts "Hello world!"
			@threads ||= []
			message = nil
			@threads << Thread.new(sock) do |sock|
				Thread.abort_on_exception = true
				loop do
					Thread.stop
					sock.puts message[:message]
				end
			end
			loop do
				sock.print "Enter a message to tell the world: "
				message = {:time => Time.new, :message => sock.gets}
				if message[:message][0] == "/"
					self.proccess_command message[:message][1..-1], sock
				else
					@threads.each do |thread|
					 	thread.run if thread.status == "sleep"
					end
				end
			end
		end
	end
	
	def initialize
		
		server = ChatServer.new :Port => 9399

		trap('INT') { server.shutdown }


		begin
			server.start
		rescue 
			server.shutdown
		end
	end
	
	
end

if __FILE__ == $0
	ChatRunner.new
end

