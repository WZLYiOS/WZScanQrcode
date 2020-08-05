//
//  WZPermissions.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import Photos
import Foundation
import AVFoundation
import AssetsLibrary


/// MARK - 权限
public class WZPermissions: NSObject {
    
    /// MARK - 获取相册权限
    public static func authorizePhoto(comletion: @escaping (Bool) -> Void)
    {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case .authorized:
            comletion(true)
        case .denied, .restricted:
            comletion(false)
        default:
            PHPhotoLibrary.requestAuthorization({ (state) in
                DispatchQueue.main.async {
                    comletion(state == PHAuthorizationStatus.authorized ? true : false)
                }
            })
        }
    }
    
    /// MARK - 相机权限
    public static func authorizeCamera(comletion: @escaping (Bool) -> Void)
    {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch granted {
        case .authorized:
            comletion(true)
        case .denied:
            comletion(false)
        case .restricted:
            comletion(false)
        default:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    comletion(granted)
                }
            })
        }
    }
    
    /// MARK - 跳转到APP系统设置权限界面
    public static func jumpToSystemPrivacySetting()
    {
        guard let appSetting = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appSetting)
        }
    }
}

