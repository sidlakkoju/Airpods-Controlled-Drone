//
//  SocketManger.swift
//  Airpods Control
//
//  Created by Siddharth Lakkoju on 3/23/24.
//

import Foundation
import CocoaAsyncSocket


class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {
    var socket: GCDAsyncUdpSocket?
    let sendHost = "192.168.10.1"
    let sendPort: UInt16 = 8889
    let statePort: UInt16 = 8890
    
    override init() {
        super.init()
        setupCommand()
        setupListener()
    }

    
    func setupCommand() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try socket?.bind(toPort: sendPort)
            try socket?.enableBroadcast(true)
            try socket?.beginReceiving()
            socket?.send("command".data(using: String.Encoding.utf8)!,
                         toHost: sendHost,
                         port: sendPort,
                         withTimeout: -1,
                         tag: 0)
        } catch {
            print("Command setup failed with error: \(error)")
        }
    }
    
    
    func setupListener() {
        do {
            try socket?.bind(toPort: statePort)
        } catch {
            print("Bind Problem: \(error)")
        }
        
        do {
            try socket?.beginReceiving()
        } catch {
            print("Receiving Problem: \(error)")
        }
    }

    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let dataString: String? = String(data: data, encoding: String.Encoding.utf8)
         if (sock.localPort() == sendPort) {
             print(dataString ?? "No data")
         }
         if (sock.localPort() == statePort) {
             print(dataString ?? "No data")
         }
    }
    
    func sendCommand(command: String) {
        let message = command.data(using: String.Encoding.utf8)
        socket?.send(message!, toHost: sendHost, port: sendPort, withTimeout: 2, tag: 0)
    }
}
