#Chat Server

This chat server allows you to talk with friends, old and new. It includes rooms and other features.

##Installation

1. Open Terminal.
2. Execute command `git clone https://github.com/roshkins/chatserver.git Chatserver`.
3. Navigate to the new directory: `cd Chatserver`
4. make sure the correct ruby version is installed: `ruby -v`. The output should include the phrase `ruby 1.9.3`.
5. run `ruby server.rb 9399` Replace `9399` with whichever port you want the server to run on.
6. Enjoy! Connect any telnet client to your ip and your specified port.
7. Press ctrl+c TWICE to exit.

##Usage

In any telnet client you may type to speak, followed by pressing enter. By default anybody who is not in a room will see your chat message. 

Here are some commands:

|Command|Description|
|:------|:----------|
|`/help`|Displays a list of commands|
|`/quit`|Quits your chat session|
|`/rooms`|Displays rooms to chat in|
|`/join room`|Joins room named 'room'. 'room' can be any word or phrase. If it's in the /rooms list then other people are already talking. If not, it creates a new room and puts you in it|
|`/leave`|Leaves your current room|
|`/users`|Displays a list of users currently in the room|

##Live server

A live server is being hosted at ip `54.213.27.31` on port `9399`.