//
//  WZScanViewController.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


/// MARK - 扫码控制器协议
public protocol WZScanViewControllerDelegate: NSObjectProtocol {
    
    func scanFinished(vc: WZScanViewController, scanResult: WZScanResult)
}


/// MARK - 扫描控制器
open class WZScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// MARK - 委托
    weak public var scanResultDelegate: WZScanViewControllerDelegate?
    
    /// MARK -  扫码设备
    private lazy var scanWrapper: WZScanWrapper = {
        
        let tem = WZScanWrapper(videoPreView: self.view, isCaptureImg: isNeedCodeImage, success: { [weak self] (result) -> Void in
            
            guard let self = self else { return }
            self.handle(code: result)
        })
        
        return tem
    }()
    
    /// MARK - 扫描风格
    open var scanStyle: WZScanViewConfig = WZScanViewConfig() {
        didSet {
            qrScanView.viewStyle = scanStyle
        }
    }
    
    /// MARK - 扫描View
    private lazy var qrScanView: WZScanView = {
        
        let tem = WZScanView(frame: self.view.frame)
        tem.viewStyle = scanStyle
        return tem
    }()
    
    /// MARK - 启动区域识别功能
    open var isOpenInterestRect = false
    
    /// MARK - 识别码类型数组
    public var arrayCodeType: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.code128]
    
    /// MARK - 是否需要识别后的当前图像
    public var isNeedCodeImage = false
    
    /// MARK - 相机启动提示文字
    public var readyString: String! = "loading"
    
    /// MARK -  扫码区域底部提示文案
    public lazy var bottomTitle: UILabel = {
        
        let temLabel = UILabel()
        temLabel.font = UIFont.systemFont(ofSize: 15)
        temLabel.textAlignment = .center
        temLabel.textColor = UIColor.white
        return temLabel
    }()
    
    /// MARK - viewDidLoad
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    /// MARK - viewWillAppear
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// MARK - viewDidAppear
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        WZPermissions.authorizeCamera { [weak self] (granted) in
            
            guard let self = self else { return }
            
            if granted {
                self.drawScanView()
                self.perform(#selector(WZScanViewController.startScan), with: nil, afterDelay: 0.3)
            } else {
                self.privacySetting()
            }
        }
    }
    
    /// MARK - 重新开始
    public func reloadStart() {
        scanWrapper.start()
    }
    
    /// MARK - 设置权限
    open func  privacySetting() {
        
        let alertController = UIAlertController(title: "开启相机权限", message: "未获得相机权限,无法扫描二维码", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] _ in
            
            guard let self = self else { return }
            
            if self.isBeingPresented {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "去开启", style: .default, handler: { _ in
            WZPermissions.jumpToSystemPrivacySetting()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    
    /// MARK - 开始扫描
    @objc open func startScan() {
        
        /// 启动区域识别功能
        if isOpenInterestRect {
            scanWrapper.output.rectOfInterest = WZScanView.getScanRect(preView: view, style: scanStyle)
        }
        
        /// buttom 位置
        if bottomTitle.frame.width <= 0 {
            bottomTitle.frame = CGRect(x: 0, y: qrScanView.scanRetangleRect.maxY + 20, width: view.frame.width, height: 20)
        }
        
        // 识别类型
        scanWrapper.output.metadataObjectTypes = arrayCodeType
        
        //结束相机等待提示
        qrScanView.deviceStopReadying()
        
        //开始扫描动画
        qrScanView.startScanAnimation()
        
        //相机运行
        scanWrapper.start()
    }
    
    /// MARK - 绘制扫描View
    private func drawScanView() {
        
        view.addSubview(qrScanView)
        view.addSubview(bottomTitle)
        qrScanView.deviceStartReadying(readyStr: readyString)
    }
    
    
    /// MARK - 处理扫码结果
    open func handle(code: WZScanResult) {
        
        if let delegate = scanResultDelegate  {
            
            delegate.scanFinished(vc: self, scanResult: code)
        } else {
            
            showMsg(title: code.strBarCodeType, message: code.strScanned)
        }
    }
    
    /// MARK - viewWillDisappear
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        qrScanView.stopScanAnimation()
        scanWrapper.stop()
    }
    
    
    /// MARK - 打开相册
    open func openPhotoAlbum() {
        
        WZPermissions.authorizePhoto { [weak self] (granted) in
            
            guard let self = self else { return }
            
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    /// 打开或者关闭闪关灯
    open func changeTorch() -> Bool {
        scanWrapper.changeTorch()
        return scanWrapper.torchMode
    }
    
    /// MARK - 相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        var image: UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if let temImage = image {
            
            if let temResult = WZScanWrapper.recognizeQRImage(image: temImage) {
                handle(code: temResult)
            } else {
                showMsg(title: nil, message: "识别失败")
            }
        }
        
        showMsg(title: nil, message: "识别失败")
    }
    
    
    /// MARK - 提示语
    private func showMsg(title: String?, message: String?) {
        
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (alertAction) in
            // do thing
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    /// MARK - 释放
    deinit {
        debugPrint("释放ScanViewController")
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

