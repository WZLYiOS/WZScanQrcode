//
//  WZScanWrapper.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit
import AVFoundation

/// MARK - 扫码包装
public class WZScanWrapper: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    /// MARK - 设备
    private let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    /// MARK - 设备输入
    private lazy var input: AVCaptureDeviceInput? = {
        
        let tem = try? AVCaptureDeviceInput(device: device!)
        return tem
    }()
    
    /// MARK - 输出数据
    public lazy var output: AVCaptureMetadataOutput = {
        
        let tem = AVCaptureMetadataOutput()
        return tem
    }()
    
    /// MARK - 绘画
    private let session = AVCaptureSession()
    
    /// MARK - previewLayer
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        
        let tem = AVCaptureVideoPreviewLayer(session: session)
        return tem
    }()
    
    /// MARK - AVCaptureStillImageOutput
    private var stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
    /// MARK - 存储返回结果
    private var result: WZScanResult?
    
    /// MARK - 扫码结果返回block
    private var successBlock: (WZScanResult) -> Void
    
    /// 是否需要拍照
    private var isNeedCaptureImage: Bool
    
    /// 当前扫码结果是否处理
    private var isNeedScanResult: Bool = true
    
    /// MARK - 散光灯是否开启
    public var torchMode: Bool {
        
        return input?.device.torchMode == AVCaptureDevice.TorchMode.on ? true: false
    }
    
    /// MARK - 是否支持闪光灯
    public var hasTorch: Bool {
        
        guard let tem = device else {
            return false
        }
        
        if tem.hasFlash && tem.hasTorch {
            return true
        } else {
            return false
        }
    }
    
    
    /**
     初始化设备
     - parameter videoPreView: 视频显示UIView
     - parameter objType:      识别码的类型,缺省值 QR二维码
     - parameter isCaptureImg: 识别后是否采集当前照片
     - parameter cropRect:     识别区域
     - parameter success:      返回识别信息
     - returns:
     */
    init(videoPreView: UIView, objType: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.qr], isCaptureImg: Bool, cropRect:CGRect = CGRect.zero, success: @escaping ((WZScanResult) -> Void))
    {
        successBlock = success
        isNeedCaptureImage = isCaptureImg
        
        super.init()
        
        guard let temDevice = device,
            let temInput = input else {
                return
        }
        
        if session.canAddInput(temInput) {
            session.addInput(temInput)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
        
        let outputSettings: Dictionary = [AVVideoCodecJPEG: AVVideoCodecKey]
        stillImageOutput.outputSettings = outputSettings
        
        session.sessionPreset = AVCaptureSession.Preset.high
        
        //参数设置
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = objType
        
        if !cropRect.equalTo(CGRect.zero) {
            
            /// 启动相机后,直接修改该参数无效
            output.rectOfInterest = cropRect
        }
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        var frame:CGRect = videoPreView.frame
        frame.origin = CGPoint.zero
        previewLayer.frame = frame
        videoPreView.layer.insertSublayer(previewLayer, at: 0)
        
        if temDevice.isFocusPointOfInterestSupported && temDevice.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
            
            do {
                try temInput.device.lockForConfiguration()
                temInput.device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                temInput.device.unlockForConfiguration()
            }
            catch let error as NSError {
                debugPrint("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureOutput(output, didOutputMetadataObjects: metadataObjects, from: connection)
    }
    
    /// MARK - 开始扫描
    func start()
    {
        if !session.isRunning
        {
            isNeedScanResult = true
            session.startRunning()
        }
    }
    
    /// MARK - 停止扫描
    func stop()
    {
        if session.isRunning
        {
            isNeedScanResult = false
            session.stopRunning()
        }
    }
    
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if !isNeedScanResult {
            
            //上一帧处理中
            return
        }
        
        isNeedScanResult = false
        
        result = nil
        
        //识别扫码类型
        for current: Any in metadataObjects
        {
            if (current as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self)
            {
                let code = current as! AVMetadataMachineReadableCodeObject
                
                //码类型
                let codeType = code.type
                
                //码内容
                let codeContent = code.stringValue
                
                
                //4个字典，分别 左上角-右上角-右下角-左下角的 坐标百分百，可以使用这个比例抠出码的图像
                result = WZScanResult(strScanned: codeContent, imgScanned: UIImage(), strBarCodeType: codeType.rawValue, arrayCorner: code.corners as [AnyObject])
            }
        }
        
        if let temResult = result {
            
            if isNeedCaptureImage {
                captureImage(result: temResult)
            } else {
                stop()
                successBlock(temResult)
            }
            
        } else {
            isNeedScanResult = true
        }
    }
    
    /// MARK - 拍照
    public func captureImage(result: WZScanResult) {
        
        var temResult = result
        
        let stillImageConnection: AVCaptureConnection? = connectionWithMediaType(mediaType: AVMediaType.video, connections: stillImageOutput.connections as [AnyObject])
        
        
        stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection!, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            self.stop()
            if imageDataSampleBuffer != nil {
                let imageData: Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)!
                let scanImg : UIImage? = UIImage(data: imageData)
                
                temResult.imgScanned = scanImg
            }
            
            self.successBlock(temResult)
        })
    }
    
    public func connectionWithMediaType(mediaType:AVMediaType,connections:[AnyObject]) -> AVCaptureConnection?
    {
        for connection:AnyObject in connections
        {
            let connectionTmp:AVCaptureConnection = connection as! AVCaptureConnection
            
            for port:Any in connectionTmp.inputPorts
            {
                if (port as AnyObject).isKind(of: AVCaptureInput.Port.self)
                {
                    let portTmp:AVCaptureInput.Port = port as! AVCaptureInput.Port
                    if portTmp.mediaType == mediaType
                    {
                        return connectionTmp
                    }
                }
            }
        }
        return nil
    }
    
    
    /// MARK - 切换识别区域
    public func changeScan(rect: CGRect) {
        
        /// 待测试，不知道是否有效
        stop()
        output.rectOfInterest = rect
        start()
    }
    
    /// MARK - 切换识别码的类型
    public func changeScan(objType: [AVMetadataObject.ObjectType]) {
        
        //待测试中途修改是否有效
        output.metadataObjectTypes = objType
    }
    
    
    /// MARK - 打开或关闭闪关灯
    public func setTorch(torch: Bool) {
        
        if self.hasTorch {
            
            do {
                try input?.device.lockForConfiguration()
                input?.device.torchMode = torch ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
                input?.device.unlockForConfiguration()
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    
    
    /// MARK - 闪光灯打开或关闭
    public func changeTorch() {
        
        if self.hasTorch {
            
            do {
                try input?.device.lockForConfiguration()
                
                var torch = false
                if input?.device.torchMode == AVCaptureDevice.TorchMode.on {
                    
                    torch = false
                    
                } else if input?.device.torchMode == AVCaptureDevice.TorchMode.off {
                    
                    torch = true
                }
                
                input?.device.torchMode = torch ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
                input?.device.unlockForConfiguration()
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    /// MARK - 获取系统默认支持的码的类型
    static func defaultMetaDataObjectTypes() ->[AVMetadataObject.ObjectType] {
        
        var types = [AVMetadataObject.ObjectType.qr,
                     AVMetadataObject.ObjectType.upce,
                     AVMetadataObject.ObjectType.code39,
                     AVMetadataObject.ObjectType.code39Mod43,
                     AVMetadataObject.ObjectType.ean13,
                     AVMetadataObject.ObjectType.ean8,
                     AVMetadataObject.ObjectType.code93,
                     AVMetadataObject.ObjectType.code128,
                     AVMetadataObject.ObjectType.pdf417,
                     AVMetadataObject.ObjectType.aztec,
                     
                     ]
        
        types.append(AVMetadataObject.ObjectType.interleaved2of5)
        types.append(AVMetadataObject.ObjectType.itf14)
        types.append(AVMetadataObject.ObjectType.dataMatrix)
        
        types.append(AVMetadataObject.ObjectType.interleaved2of5)
        types.append(AVMetadataObject.ObjectType.itf14)
        types.append(AVMetadataObject.ObjectType.dataMatrix)
        
        return types as [AVMetadataObject.ObjectType]
    }
    
    
    /// MARK - 识别二维码码图像(目前只有屏幕截图的才可以识别,拍照的二维码还不能识别,原因不详。待续)
    static public func recognizeQRImage(image: UIImage) -> WZScanResult? {
        
        var returnResult: WZScanResult?
        
        let opts = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: opts)!
        let img = CIImage(image: image)!
        let features = detector.features(in: img)
        
        for item in features {
            
            if let tem = item as? CIQRCodeFeature {
                returnResult = WZScanResult(strScanned: tem.messageString, imgScanned: nil, strBarCodeType: nil, arrayCorner: nil)
                break
            }
            return nil
        }
        return returnResult
    }
    
    
    
    /// MARK - 生成二维码,背景色及二维码颜色设置
    static public func createCode(codeType: String, codeString: String, size: CGSize, qrColor: UIColor, bkColor: UIColor) -> UIImage? {
        
        let stringData = codeString.data(using: String.Encoding.utf8)
        
        //系统自带能生成的码
        guard let qrFilter = CIFilter(name: codeType)  else {
            return nil
        }
        
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        /// 上颜色
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: [
            "inputImage": qrFilter.outputImage!,
            "inputColor0": CIColor(cgColor: qrColor.cgColor),
            "inputColor1": CIColor(cgColor: bkColor.cgColor)
            ])
        
        
        let qrImage = colorFilter!.outputImage!
        
        //绘制
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent)!
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = CGInterpolationQuality.none
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return codeImage
    }
    
    /// MARK - 创建Code128编码
    static public func createCode128(codeString: String, size: CGSize, qrColor: UIColor, bkColor: UIColor) -> UIImage? {
        
        let stringData = codeString.data(using: String.Encoding.utf8)
        
        /// 系统自带能生成的码
        guard let qrFilter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        qrFilter.setDefaults()
        qrFilter.setValue(stringData, forKey: "inputMessage")
        let outputImage: CIImage? = qrFilter.outputImage
        let context = CIContext()
        let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        
        let image = UIImage(cgImage: cgImage!, scale: 1.0, orientation: UIImage.Orientation.up)
        
        
        // Resize without interpolating
        let scaleRate:CGFloat = 20.0
        let resized = resizeImage(image: image, quality: CGInterpolationQuality.none, rate: scaleRate)
        
        return resized
    }
    
    
    /// MARK - 根据扫描结果,获取图像中得二维码区域图像（如果相机拍摄角度故意很倾斜，获取的图像效果很差）
    static func getConcreteCodeImage(srcCodeImage: UIImage, codeResult: WZScanResult) -> UIImage? {
        
        let rect: CGRect = getConcreteCodeRectFromImage(srcCodeImage: srcCodeImage, codeResult: codeResult)
        
        if rect.isEmpty {
            return nil
        }
        
        let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect)
        
        if img != nil {
            let imgRotation = imageRotation(image: img!, orientation: UIImage.Orientation.right)
            return imgRotation
        }
        return nil
    }
    
    
    /// MARK - 根据二维码的区域截取二维码区域图像
    static public func getConcreteCodeImage(srcCodeImage: UIImage, rect: CGRect) -> UIImage? {
        
        if rect.isEmpty {
            return nil
        }
        
        let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect)
        
        if img != nil {
            let imgRotation = imageRotation(image: img!, orientation: UIImage.Orientation.right)
            return imgRotation
        }
        return nil
    }
    
    /// MARK - 获取二维码的图像区域
    static public func getConcreteCodeRectFromImage(srcCodeImage: UIImage, codeResult: WZScanResult) -> CGRect {
        
        if (codeResult.arrayCorner == nil || (codeResult.arrayCorner?.count)! < 4) {
            return CGRect.zero
        }
        
        let corner: [[String:Float]] = codeResult.arrayCorner as! [[String:Float]]
        
        let dicTopLeft     = corner[0]
        let dicTopRight    = corner[1]
        let dicBottomRight = corner[2]
        let dicBottomLeft  = corner[3]
        
        let xLeftTopRatio:Float = dicTopLeft["X"]!
        let yLeftTopRatio:Float  = dicTopLeft["Y"]!
        
        let xRightTopRatio:Float = dicTopRight["X"]!
        let yRightTopRatio:Float = dicTopRight["Y"]!
        
        let xBottomRightRatio:Float = dicBottomRight["X"]!
        let yBottomRightRatio:Float = dicBottomRight["Y"]!
        
        let xLeftBottomRatio:Float = dicBottomLeft["X"]!
        let yLeftBottomRatio:Float = dicBottomLeft["Y"]!
        
        //由于截图只能矩形，所以截图不规则四边形的最大外围
        let xMinLeft = CGFloat( min(xLeftTopRatio, xLeftBottomRatio) )
        let xMaxRight = CGFloat( max(xRightTopRatio, xBottomRightRatio) )
        
        let yMinTop = CGFloat( min(yLeftTopRatio, yRightTopRatio) )
        let yMaxBottom = CGFloat ( max(yLeftBottomRatio, yBottomRightRatio) )
        
        let imgW = srcCodeImage.size.width
        let imgH = srcCodeImage.size.height
        
        //宽高反过来计算
        let rect = CGRect(x: xMinLeft * imgH, y: yMinTop*imgW, width: (xMaxRight-xMinLeft)*imgH, height: (yMaxBottom-yMinTop)*imgW)
        return rect
    }
    
    //MARK: ----图像处理
    
    /**
     @brief  图像中间加logo图片
     @param  srcImg    原图像
     @param  LogoImage logo图像
     @param  logoSize  logo图像尺寸
     @return 加Logo的图像
     */
    static public func addImageLogo(srcImg: UIImage, logoImg: UIImage, logoSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(srcImg.size)
        
        srcImg.draw(in: CGRect(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        let rect = CGRect(x: srcImg.size.width/2 - logoSize.width/2, y: srcImg.size.height/2-logoSize.height/2, width:logoSize.width, height: logoSize.height)
        logoImg.draw(in: rect)
        
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultingImage!
    }
    
    /// MARK - 图像缩放
    static func resizeImage(image: UIImage, quality: CGInterpolationQuality, rate: CGFloat) -> UIImage? {
        
        var resized: UIImage?
        let width = image.size.width * rate
        let height = image.size.height * rate
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = quality
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized
    }
    
    /// MARK - 图像裁剪
    static func imageByCroppingWithStyle(srcImg: UIImage, rect: CGRect) -> UIImage? {
        
        let imageRef = srcImg.cgImage
        let imagePartRef = imageRef!.cropping(to: rect)
        let cropImage = UIImage(cgImage: imagePartRef!)
        return cropImage
    }
    
    /// MARK - 图像旋转
    static func imageRotation(image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        
        var rotate: Double = 0.0
        var rect: CGRect
        var translateX: CGFloat = 0.0
        var translateY: CGFloat = 0.0
        var scaleX: CGFloat = 1.0
        var scaleY: CGFloat = 1.0
        
        switch (orientation) {
        case UIImage.Orientation.left:
            
            rotate = .pi/2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = 0
            translateY = -rect.size.width
            scaleY = rect.size.width/rect.size.height
            scaleX = rect.size.height/rect.size.width
        case UIImage.Orientation.right:
            
            rotate = 3 * .pi/2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = -rect.size.height
            translateY = 0
            scaleY = rect.size.width/rect.size.height
            scaleX = rect.size.height/rect.size.width
        case UIImage.Orientation.down:
            
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = -rect.size.width
            translateY = -rect.size.height
            break
            
        default:
            
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = 0
            translateY = 0
            break
        }
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        //做CTM变换
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: translateX, y: translateY)
        
        context.scaleBy(x: scaleX, y: scaleY)
        
        //绘制图片
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let newPic = UIGraphicsGetImageFromCurrentImageContext()
        return newPic!
    }
    
    deinit {
        debugPrint("释放ScanWrapper")
    }
}
