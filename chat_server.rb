require 'webrick'
require 'thread'

class ChatRunner
	class ChatServer < WEBrick::GenericServer

		def run(sock)
			sock.puts "Hello world!"
			@threads ||= []
			mutex = Mutex.new
			@message = nil
			@threads << Thread.new(sock) do |sock|
				Thread.abort_on_exception = true
				loop do
					Thread.stop
					sock.puts @message[:message]
				end
			end
			loop do
				sock.print "Enter a message to tell the world: "
				mutex.synchronize do
					@message = {:time => Time.new, :message=> sock.gets}
				end
				@threads.each do |thread|
					p thread.status
				 	thread.run if thread.status == "sleep"
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

