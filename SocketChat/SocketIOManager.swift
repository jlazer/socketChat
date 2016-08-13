//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Justin Lazarski on 8/13/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    // Adopting the Singleton pattern for this class, so we can easily access it from anywhere else in our code.
    static let sharedInstance = SocketIOManager()
    // Declaring a property of type SocketIOClient. This is the basic class of Socket.IO that will enable us to send and recieve messages from the server. As Swift is flexible enough we'll initialise that property in the same line, and we'll provide the IP address of our computer and the designated port  as arguments upon initialisation.
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.221:3000")!)
    
    override init() {
        super.init()
        
    }
    
    // Let's define two methods now that will make use of the above socket property. The first one connects the app to the server, and the second makes the disconnection.
    // As you see, all you need is two commands only: socket.connect() and socket.disconnect(). No hassle for performing the connection at all, as that is totally handled by the Socket.IO under the hood when you ask for it, and that's a huge benefit for us.
    // The above two methods must be used somehow now. We are going to establish a conection to the server whenever the app becomes active, and we'll close that connection when it enters the background. Simple enough, so open the AppDelegate.swift file and in the delegate method you see next call the first one defined above.
    func establishConnection() {
        socket.connect()
    }
    func closeConnection() {
        socket.disconnect()
    }
    // Send a new user's nickname to the server, using of course the Socket.IO libray.
    func connectToServerWithNickname(nickname: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        // Sending the nickname to the server takes one line only, the following:
        socket.emit("connectUser", nickname)
        // The emit(...) method of the socket object is what we need for sending any message to the server using the Socket.IO client library.
        // The above line is simply sending the server a single message named connectUser, along with one parameter (one piece of data, the user nickname). On the other side, the server is listening for incoming messages to the socket, and when such a message arrives, it instantly performs the following tasks:
        //  1. It checks if the user is a new one or not. In the first case it stores the new user in its internal array (client ID, nickname, connected state), otherwise it updates the connected state by setting it true.
        //  2. It returns its user list updated so it contains the recently connected user as well.
        // Note: You can actually see the server-side actions of this part if you open the index.js file in the srv-SocketChat folder, and search for the MARKDOWN_HASH69adb32223120a64c2bfaa1bcf690c7fMARKDOWN_HASH function.
        // We need to listen to the socket for any message regarding the user list, and grab it when it comes back from the server. To listen for incoming messages to and iOS app, we have to use the on(...) method of the socket object like we do below.
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
            // When the user list is received from the server, we call our own method's completion handler passing as an argument that list. It is obvioulsy an array with dictionaries as objects, and that's why the conversion above is necessary to happen.
            // Important notice: The above socket.on(...) method will be invoked automatically by the Socket.IO every time that the server sends the user list. Simply put, the app will keep listenig for the "userList" message endlessly, and when such one arrives it will call our completion handler. Of course, all that activity stops when the app gets disconnected from the server.
        }
    }
    // Our server immediately understands that it must delete the specified user when it recieves the "exitUser" message, and that's exactly what it does.
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    // When the server recieves "chatMessage", it will emit in turn that message to all connected users. All this communication will take place almost instantly, so any new message will appear to all users in real time. And that's what exactly we want to achieve by using the SocketIO library.
    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    // This method listens for new incoming chat messages:
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            // The dictionary is returned back to the caller of the method through the completion handler. Note once again that the on(...) method will be automatically invoked from now on everytime a new chat message is recieved.
            completionHandler(messageInfo: messageDictionary)
    }
        
    
    
    
    
    
}
}