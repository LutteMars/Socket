//
//  NetWorkAPI.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//

import Foundation
import UIKit

typealias successBlock = (_ status: String) -> ()

class NetWorkAPI: NSObject {
    var disconnectView: UIView!
    
    class var sharedInstance: NetWorkAPI {
        struct Singleton {
            static let instance = NetWorkAPI()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
    }
    
    // 监听网络类型和状态
    func monitorNetwork(_ VC: UIView) {
        print("**********开始使用Alamofire进行网络状态监测********")
        
        // 使用Alamofire进行网络状态监测
        let manager = NetworkReachabilityManager(host: SERVICE_ADDRESS)
        //            let status = manager?.networkReachabilityStatus
        
        // 注册监听者并对状态进行判断
        manager?.listener = { status in
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable {
                // The network is not reachable.
                TcpHandler.sharedInstance.sendMessageForExit(VC)
                TcpAPI.sharedInstance.isConnect = false
                LogAPI.log("----------------网络是不可到达的------------------")
                return
            } else if status == NetworkReachabilityManager.NetworkReachabilityStatus.reachable(NetworkReachabilityManager.ConnectionType.wwan) {
                // The network is reachable over the WWAN connection
//                self.buildSocket()
                LogAPI.log("----------------通过无线广域网连接网络------------------")
            } else if status == NetworkReachabilityManager.NetworkReachabilityStatus.reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi) {
                // The network is reachable over the WiFi connection.
//                self.buildSocket()
                LogAPI.log("----------------通过WIFI连接网络------------------")
            } else if status == NetworkReachabilityManager.NetworkReachabilityStatus.unknown {
                // It is unknown whether the network is reachable
                TcpHandler.sharedInstance.sendMessageForExit(VC)
                TcpAPI.sharedInstance.isConnect = false
                LogAPI.log("----------------无法辨别当前网络的类型------------------")
                return
            }
            
            // 在可联网的情况下建立socket连接
            self.buildSocket()
            
        }
        
        // 开始执行监听网络类型与状态操作
        manager?.startListening()
        
    }
    
    func buildSocket() {
        // 如果socket连接还没有建立则建立socket连接并执行自动登录操作
        if TcpAPI.sharedInstance.isConnect == false {
            TcpAPI.sharedInstance.socketConnectHost()
            TcpHandler.sharedInstance.sendMessageForLogin()
            TcpAPI.sharedInstance.isConnect = true
        }
    }
    
}
