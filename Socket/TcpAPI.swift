
//
//  TcpAPI.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//

import Foundation

enum SocketOffline: Int {
    case SocketOffineByServer   // 服务器掉线
    case SocketOffineByUser     // 用户主动断开
}

typealias receiveBlock = (_ result: String) -> Void

class TcpAPI: NSObject, AsyncSocketDelegate {
    var socket: AsyncSocket!
    var connectTimer: Timer!  // 发送心跳包时间间隔
    var socketHost: String!
    var socketPost: UInt16!
    var receiveData: receiveBlock?
    var flag = true
    var disconnectView: UIView?
    
    var isConnect: Bool = true
    
    class var sharedInstance: TcpAPI {
        struct Singleton {
            static let instance = TcpAPI()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        // 需要连接的服务器端的地址和端口号
        socketHost = SERVICE_ADDRESS
        socketPost = SOCKET_POST
    }
    
    // 建立socket连接
    func socketConnectHost() {
        socket = AsyncSocket(delegate: nil)
        socket.disconnect()
        socket = nil
        socket = AsyncSocket(delegate: self)
        
        do {
            try socket.connect(toHost: socketHost,onPort: socketPost, withTimeout: -1)
        } catch let error as NSError {
            print(error)  // socket连接出错
        }
    }
    
    // 连接成功回调
    func onSocket(_ sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        LogAPI.log("-----------socket连接成功！------------")
        socket.readData(withTimeout: -1, tag: 200)
        CommonAPI.postNotice(name: "TcpConnectOkNotification")
        flag = true
        
        // 每隔30s向服务器发送心跳包
        self.connectTimer = Timer(timeInterval: 30, target: self, selector: #selector(TcpAPI.longConnectToSocket), userInfo: nil, repeats: true)

        self.connectTimer.fire()
    }
    
    // 有新的socket连接建立
    func onSocket(_ sock: AsyncSocket!, didAcceptNewSocket newSocket: AsyncSocket!) {
        LogAPI.log("------有新的socket连接建立-------")
        newSocket.readData(withTimeout: -1, tag: 200)
    }
    
    // 心跳连接
    func longConnectToSocket() {
        self.sendMessage(message: "---------已经建立长连接--------")
    }
    
    // 发送消息
    func sendMessage(message: String) {
        print(message)
        
        let dataStream: Data = message.data(using: String.Encoding.utf8)!
        if self.socket != nil {
            // 发送数据到服务器端
            self.socket.write(dataStream, withTimeout:60, tag: 100)
        } else {
            LogAPI.log("------网络连接已经断开-----")
            return
        }
    }
    
    // 发送消息成功之后的回调
    func onSocket(_ sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        LogAPI.log("---------消息发送成功-------")
    }
    
    // 接收消息成功之后的回调
    func onSocket(_ sock: AsyncSocket!, didRead data: Data!, withTag tag: Int) {
        let result: String = String(data: data, encoding: String.Encoding.utf8)!
        LogAPI.log("---收到的数据：\(result)")
        // 此处对接收到的数据做分发处理，根据实际情况与不同需求来操作
        // ......
        self.receiveData!(result)
        // 接收socket数据
        self.socket.readData(withTimeout: -1, buffer: nil, bufferOffset: 0, maxLength: 5000,tag: 200)
    }
    
    // 已经失去socket连接
    func onSocketDidDisconnect(_ sock: AsyncSocket!) {
        LogAPI.log("------已经失去socket连接：\(socket.userData())-----")
        
        // 注册一个通知中心事件
        if flag {
            CommonAPI.postNotice(name: "TcpDisconnectNotification")
            flag = false
        }
        
        // 判断是服务器端断开socket连接还是客户端断开socket连接
        switch socket.userData() {
        // 1.如果是服务器端断开连接则重新建立连接
        case SocketOffline.SocketOffineByServer.rawValue:
            self.socketConnectHost()
            break
        // 2.如果是客户端断开连接
        case SocketOffline.SocketOffineByUser.rawValue:
            let account = CommonAPI.getUserDefaults("accountID")
            if (account != nil) && ((account as! String) != "") {
                LogAPI.log("-----用户:\(account as! String)手动断开了socket连接！-----")
            }
            break
        default:
            break
        }
    }
    
    // 执行断开socket连接操作
    func cutOffSocket() {
        if self.socket != nil {
            self.socket.setUserData(SocketOffline.SocketOffineByUser.rawValue)
            self.socket.disconnect()
        } else {
            CommonAPI.showError(error: "-----网络连接已经断开！-----",view: disconnectView!)
        }
    }
    
}
