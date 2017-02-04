//
//  SocketIOManager.swift
//  DrawAndGuess
//
//  Created by Troy on 2017/2/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
    
    var socket = SocketIOClient(socketURL: URL(string: "http://160.39.237.216:4000")!)
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func nextRound() {
        socket.emit("nextRound")
    }
    
    
    func drawLine(fromX:Double, fromY:Double, toX:Double, toY:Double) {
        socket.emit("drawLine", fromX, fromY, toX, toY)
    }
    
    func resetCanvas() {
        socket.emit("resetCanvas")
    }
    
    
    func sendGuess(guess:String) {
        socket.emit("sendGuess", guess, UserDefaults.standard.string(forKey: "userID")!)
    }
    
    func receiveDrawLine(completionHandler:@escaping (_ points:[Double]) -> Void) {
        socket.on("receiveDrawLine", callback: {(dataArray, socketAck) in
            completionHandler(dataArray as! [Double])
        })
    }
    
    func receiveResetCanvas(completionHandler:@escaping () -> Void) {
        socket.on("receiveResetCanvas", callback: {(dataArray, socketAck) in
            completionHandler()
        })
    }
    
    func receiveSendGuess(completionHandler:@escaping (_ guess:String, _ userID:String, _ verdict:String) -> Void) {
        socket.on("receiveSendGuess", callback: {(dataArray, socketAck) in
            completionHandler(dataArray[0] as! String,dataArray[1] as! String,dataArray[2] as! String)
        })
    }
    
    func receiveStartNewRound(completionHandler:@escaping (_ roundCount:Int, _ keyword:String, _ hint:String, _ drawingUser:String) -> Void) {
        socket.on("receiveStartNewRound", callback: {(dataArray, socketAck) in
            completionHandler(dataArray[0] as! Int, dataArray[1] as! String,dataArray[2] as! String, dataArray[3] as! String)
        })
    }
    
    func receiveStartNewGame(completionHandler:@escaping () -> Void) {
        socket.on("receiveStartNewGame", callback: {(dataArray, socketAck) in
            completionHandler()
        })
    }
    
    func receiveUsers(completionHandler:@escaping (_ users:[[String:Any]]) -> Void) {
        socket.on("receiveUsers", callback: {(dataArray, socketAck) in
            completionHandler(dataArray[0] as! [[String: Any]])
        })
    }
    
    func receiveRevealAnswer(completionHandler:@escaping () -> Void) {
        socket.on("receiveRevealAnswer", callback: {(dataArray, socketAck) in
            completionHandler()
        })
    }
    
    func receiveAddScoreToDrawingUser(completionHandler:@escaping () -> Void) {
        socket.on("receiveAddScoreToDrawingUser", callback: {(dataArray, socketAck) in
            completionHandler()
        })
    }
    
    func connectUser(userID: String, avatar:NSData) {
        print("Connecting to server")
        socket.emit("connectUser", userID, avatar)
    }
    
    func disConnectUser(userID: String) {
        socket.emit("exitUser", userID)
    }
}
