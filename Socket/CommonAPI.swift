
//
//  CommonAPI.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//

import Foundation
import UIKit

// 结构体
struct MyRegex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: [], range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }else {
            return false
        }
    }
    
}


class CommonAPI: NSObject {
    static let userDefaults = UserDefaults.standard
    static let notice = NotificationCenter.default
    static let progressHUD = MBProgressHUD()
    
    static func getUserDefaults(_ key: String) -> AnyObject? {
        var saveData: AnyObject! = userDefaults.object(forKey: key) as AnyObject!
        
        if saveData == nil {
            saveData = "" as AnyObject!
        }
        return saveData
    }
    
    static func saveUserDefaults(_ key: String, value: AnyObject?) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static func removeUserDefault(_ key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    static func postNotice(name: String) {
         self.notice.post(Notification.init(name: Notification.Name.init(name)))
    }
    
    static func postNoticeWithObject(name: String, object: Any? = nil) {
        self.notice.post(name: NSNotification.Name(rawValue: name), object: object)
    }
    
    static func postNoticeWithObjectAndUserInfo(name: String, object: Any? = nil, userInfo: AnyObject?) {
        self.notice.post(name: NSNotification.Name(rawValue: name), object: object, userInfo: userInfo as? [AnyHashable : Any])
    }
    
    static func showTextHUDInView(_ view: UIView, text: String) {
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.text;
        hud.label.text = text;
        hud.margin = 10;
        hud.removeFromSuperViewOnHide = true;
        hud.hide(animated: true, afterDelay: 3)
    }
    
    static func show(_ text: String, icon: String) {
        let arr: NSArray = UIApplication.shared.windows as NSArray
        let view = arr.lastObject as! UIView
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text;
        hud.customView = UIImageView.init(image: UIImage(named: icon))
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1)
    }
    
    static func showError(error: String, view: UIView) {
        show(error, icon: "")
    }
    
    static func showSuccess(success: String, view: UIView) {
        show(success, icon: "")
    }
    
    
    // 验证IP地址格式是否正确
    static func checkIPAddress(maybeIPAddress: String) -> Bool {
        let IPAddressPattern = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        
        if MyRegex(IPAddressPattern).match(maybeIPAddress) {
            return true
        }
        
        return false
    }
    
}
