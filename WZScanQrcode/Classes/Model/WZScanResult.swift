//
//  WZScanResult.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit
import Foundation

/// MARK - 扫描结果实体
public struct WZScanResult {
    
    /// MARK - 码内容
    public var strScanned: String?
    
    /// MARK - 扫描图像
    public var imgScanned: UIImage?
    
    /// MARK - 码的类型
    public var strBarCodeType: String?
    
    /// MARK - 码在图像中的位置
    public var arrayCorner: [AnyObject]?
}
