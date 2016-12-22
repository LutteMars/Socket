//
//  LogAPI.swift
//  Socket
//
//  Created by junjie on 2016/12/21.
//  Copyright © 2016年 Lyndon. All rights reserved.
//

import Foundation
import UIKit

class LogAPI: NSObject {
    
    static func log(_ message: String, function: String = #function) {
        #if DEBUG
            print("\(function): \(message)")
        #endif
    }
    
    @nonobjc
    static func log(_ message: AnyObject?, function: String = #function) {
        #if DEBUG
            print("\(function): \(message)")
        #endif
    }
    
}
