//
//  TcpHandler.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//


import UIKit

class TcpHandler: NSObject {
    let tcpAPI: TcpAPI!
    var accooutId: String!
    
    var dissconnectView: UIView! // 自定义视图
    
    class var sharedInstance: TcpHandler {
        struct Singleton {
            static let instance = TcpHandler()
        }
        return Singleton.instance
    }
    
    override init() {
        tcpAPI = TcpAPI.sharedInstance
        self.accooutId = CommonAPI.getUserDefaults("accountID") as! String
    }
    
    // 发送登录相关信息
    func sendMessageForLogin() {
        self.accooutId = CommonAPI.getUserDefaults("accountID") as! String
        LogAPI.log("-----登录的ID：\(self.accooutId)-----")
        // 这里发送的信息格式需要与后台商定
        tcpAPI.sendMessage(message: "\(self.accooutId)")
        
        if self.dissconnectView != nil {
            self.dissconnectView.removeFromSuperview()
        }
    }
    
    // 发送退出相关信息
    func sendMessageForExit(_ view: UIView) {
        // 这里发送的信息格式也需要与后台商定
        tcpAPI.sendMessage(message: "\(self.accooutId)")
        // 一旦退出登录，则断开socket连接
        tcpAPI.cutOffSocket()
        
        if self.dissconnectView != nil {
            self.dissconnectView.removeFromSuperview()
        }
        // 在这里添加自定义的视图
        view.addSubview(self.dissconnectView)
    }
    
}
