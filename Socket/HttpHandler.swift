
//
//  HttpHandler.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//

//import Foundation
import UIKit

public typealias TransSuccessBlock = (_ data: AnyObject) -> Void

class HttpHandler: NSObject {
    var url: String!
    var params: [String:String]!
    var transSuccessBlock: TransSuccessBlock!
    var hud: MBProgressHUD!
    
    var manager: SessionManager!
    var response: HTTPURLResponse!
    var data: Data!
    var error: NSError!
    
    
    init(url: String, params: [String:String], transSuccessBlock: @escaping TransSuccessBlock) {
        super.init()
        
        self.url = url
        self.params = params
        self.transSuccessBlock = transSuccessBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func post(_ viewController: UIViewController) {
        postWithHUDOnView(viewController)
    }
    
    /**
     没有加载动画的网络请求
     */
    func postParams() {
        manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response { (dataResponse) in
            
            // 异常处理
            do {
                unowned let unSelf: HttpHandler = self
                let dict = try JSONSerialization.jsonObject(with: dataResponse.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                // flag:发送请求后服务器端传回的状态标识
                // msg:发送请求后服务器端传回的描述信息
                // content:发送请求后服务器端传回的数据
                let flag = (dict as AnyObject).object(forKey: "flag")!
                let msg = (dict as AnyObject).object(forKey: "msg")!
                let content = (dict as AnyObject).object(forKey: "data")!
                
                if (flag as AnyObject).intValue == 0 {
                    LogAPI.log("-----从服务器获得的数据：\(content)-----")
                    // 在这里调用block函数不添加`as AnyObject`会报错
                    unSelf.transSuccessBlock(content as AnyObject)
                } else {
                    LogAPI.log("-----从服务器请求服务错误原因：\(msg)-----")
                }
                
            } catch var aError as NSError {
                if dataResponse.error != nil {
                    aError = dataResponse.error as! NSError
                    LogAPI.log("-----网络请求异常错误：\(aError)-----")
                }
            
            }   // do - catch end>>
        
        }
        
    }
    
    /**
     带有加载动画的网络服务请求
     
     - parameter viewController: 当前视图控制器
     - parameter showHud:        是否展示加载指示图
     - parameter hudText:        加载过程中指示图文本信息
     - parameter finishHudText:  完成加载后显示的文本信息
     */
    func postWithHUDOnView(_ viewController: UIViewController!, showHud: Bool = true, hudText: String = "正在请求", finishHudText: String = "加载成功") {
        NetWorkAPI.sharedInstance.monitorNetwork(viewController.view)
        if showHud {
            self.hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
            self.hud.label.text = hudText
        }
        
        // 发起网络请求
        manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).validate().response { (dataResponse) in
            
            if showHud {
                self.hud.customView = nil
                self.hud.label.text = finishHudText
                self.hud.hide(animated: false, afterDelay: 0.2)
            }
            
            // 异常处理
            do {
                unowned let unSelf: HttpHandler = self
                let dict = try JSONSerialization.jsonObject(with: dataResponse.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                let flag = (dict as AnyObject).object(forKey: "flag")! as! Int
                let msg = (dict as AnyObject).object(forKey: "msg")! as! String
                let content = (dict as AnyObject).object(forKey: "data")!
                
                // 判断网络请求状态
                switch flag {
                case -1:
                    LogAPI.log(msg)
                    break
                case 0:
                    unSelf.transSuccessBlock(content as AnyObject)
                    break
                case 1:
                    // do something there...
                    // eg:判断应用版本是否需要更新
                   break
                default:
                    break
                }
            } catch var aError as NSError {
                if dataResponse.error != nil {
                    aError = dataResponse.error as! NSError
                    LogAPI.log("-----网络请求异常错误：\(aError)-----")
                }
                
                if showHud {
                    unowned let unSelf: HttpHandler = self
                    unSelf.hud.hide(animated: true)
                }
                
            } // do - catch end>>
            
        }
        
    }
    
}
