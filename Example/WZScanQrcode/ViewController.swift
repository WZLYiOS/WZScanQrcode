//
//  ViewController.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 08/15/2019.
//  Copyright (c) 2019 xiaobin liu. All rights reserved.
//

import UIKit
import WZScanQrcode

/// Demo
final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var tableView: UITableView!
    
    
    var arrayItems:Array<Array<String>> = [
        ["模仿支付宝扫码区域","ZhiFuBaoStyle"],
        ["模仿微信扫码区域","weixinStyle"]
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height))
        self.title = "Swift 扫一扫"
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        view.addSubview(tableView)
    }
    
    
    /// MARK -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = arrayItems[indexPath.row].first
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            self.ZhiFuBaoStyle();
        default:
            self.weixinStyle()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    /// MARK - 支付宝
    func ZhiFuBaoStyle()
    {
        //设置扫码区域参数
        var style = WZScanViewConfig()
        style.centerUpOffset = 60
        style.xScanRetangleOffset = 30
        
        if UIScreen.main.bounds.size.height <= 480 {
            //3.5inch 显示的扫码缩小
            style.centerUpOffset = 40
            style.xScanRetangleOffset = 20
        }
        
        style.notRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
        style.photoframeAngleStyle = WZScanViewPhotoframeAngleStyle.inner
        style.photoframeLineW = 2.0
        style.photoframeAngleW = 16
        style.photoframeAngleH = 16
        style.animationStyle = WZScanViewAnimationStyle.grid
        style.animationImage = UIImage(named: "qrcode_scan_full_net")
        
        let vc = WZScanViewController()
        vc.scanResultDelegate = self
        vc.isOpenInterestRect = true
        vc.scanStyle = style
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createImageWithColor(color:UIColor) -> UIImage
    {
        let rect=CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return theImage!;
    }
    
    
    //MARK: ---无边框，内嵌4个角------
    func weixinStyle()
    {
        //设置扫码区域参数
        var style = WZScanViewConfig()
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = WZScanViewPhotoframeAngleStyle.inner;
        style.photoframeLineW = 2;
        style.photoframeAngleW = 18;
        style.photoframeAngleH = 18;
        style.isNeedShowRetangle = false;
        style.animationStyle = WZScanViewAnimationStyle.line;
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "qrcode_Scan_weixin_Line")
        let vc = WZScanViewController();
        vc.scanStyle = style
        vc.scanResultDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: -------- 相册
    func openLocalPhotoAlbum()
    {
        
        WZPermissions.authorizePhoto { [weak self] (granted) in
            
            if granted {
                
                if let strongSelf = self {
                    let picker = UIImagePickerController()
                    picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    picker.delegate = self;
                    picker.allowsEditing = true
                    strongSelf.present(picker, animated: true, completion: nil)
                }
            } else {
                WZPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
    
    /// MARK - 相册选择图片识别二维码 （条形码没有找到系统方法）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var image: UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if let temImage = image {
            
            if let temResult = WZScanWrapper.recognizeQRImage(image: temImage) {
                showMsg(title: temResult.strBarCodeType, message: temResult.strScanned)
            } else {
                showMsg(title: nil, message: "识别失败")
            }
        }
        showMsg(title: nil, message: "识别失败")
    }
    
    
    func showMsg(title:String?,message:String?) {
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title:  "知道了", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - <#WZScanViewControllerDelegate#>
extension ViewController: WZScanViewControllerDelegate {
    
    func scanFinished(vc: WZScanViewController, scanResult: WZScanResult) {
        debugPrint("scanResult:\(scanResult)")
    }
}


