
//
//  WZScanView.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit

/// MARK - 扫描View
final class WZScanView: UIView {
    
    /// MARK - 扫码区域参数(默认值)
    public var viewStyle: WZScanViewConfig = WZScanViewConfig() {
        didSet {
            
            scanAnimation.animationStyle = viewStyle.animationStyle
            scanAnimation.duration = viewStyle.duration
            scanAnimation.image = viewStyle.animationImage
        }
    }
    
    /// MARK - 扫描动画View
    public lazy var scanAnimation: WZScanAnimation = {
        
        let tem = WZScanAnimation()
        return tem
    }()
    
    
    /// MARK - 扫码区域
    public var scanRetangleRect: CGRect = CGRect.zero
    
    
    /// MARK - 启动相机时,菊花等待
    public lazy var activityView: UIActivityIndicatorView = {
        
        let tem = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        tem.style = UIActivityIndicatorView.Style.whiteLarge
        return tem
    }()
    
    
    /// MARK - 启动相机中的提示文字
    public lazy var labelReadying: UILabel = {
        
        let tem = UILabel()
        tem.backgroundColor = UIColor.clear
        tem.textColor = UIColor.white
        tem.font = UIFont.systemFont(ofSize: 18.0)
        return tem
    }()
    
    
    /// MARK - 记录动画状态
    public var isAnimationing: Bool {
        
        return scanAnimation.isAnimationing
    }
    
    
    /**
     初始化扫描界面
     - parameter frame:  界面大小，一般为视频显示区域
     - parameter vstyle: 界面效果参数
     
     - returns: instancetype
     */
    public override init(frame: CGRect) {
        
        var temFrame = frame
        temFrame.origin = CGPoint.zero
        
        super.init(frame: temFrame)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(scanAnimation)
    }
    
    /// MARK - 开始扫描动画
    public func startScanAnimation() {
        
        if self.isAnimationing || self.viewStyle.animationStyle == .none {
            return
        }
        
        /// 动画位置
        scanAnimation.animationRect = getScanRectForAnimation()
        scanAnimation.startAnimating()
    }
    
    
    /// MARK - 停止扫描动画
    public func stopScanAnimation() {
        scanAnimation.stopAnimating()
    }
    
    
    /// MARK - 获取扫描位置动画
    private func getScanRectForAnimation() -> CGRect {
        
        let xRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSize(width: self.frame.size.width - xRetangleLeft*2, height: self.frame.size.width - xRetangleLeft*2)
        
        if viewStyle.whRatio != 1 {
            let w = sizeRetangle.width
            var h = w / viewStyle.whRatio
            
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //扫码区域Y轴最小坐标
        let yMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        //扫码区域坐标
        let cropRect =  CGRect(x: xRetangleLeft, y: yMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        return cropRect
    }
    
    
    /// MARK - 根据矩形区域，获取识别区域
    public static func getScanRect(preView: UIView, style: WZScanViewConfig) -> CGRect {
        
        let xRetangleLeft = style.xScanRetangleOffset
        var sizeRetangle = CGSize(width: preView.frame.size.width - xRetangleLeft*2, height: preView.frame.size.width - xRetangleLeft*2)
        
        if style.whRatio != 1 {
            
            let w = sizeRetangle.width
            var h = w / style.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //扫码区域Y轴最小坐标
        let yMinRetangle = preView.frame.size.height / 2.0 - sizeRetangle.height/2.0 - style.centerUpOffset
        //扫码区域坐标
        let cropRect =  CGRect(x: xRetangleLeft, y: yMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
        //计算兴趣区域
        var rectOfInterest:CGRect
        
        let size = preView.bounds.size
        let p1 = size.height/size.width
        
        let p2: CGFloat = 1920.0/1080.0 //使用了1080p的图像输出
        if p1 < p2 {
            let fixHeight = size.width * 1920.0 / 1080.0;
            let fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRect(x: (cropRect.origin.y + fixPadding)/fixHeight,
                                    y: cropRect.origin.x/size.width,
                                    width: cropRect.size.height/fixHeight,
                                    height: cropRect.size.width/size.width)
            
            
        } else {
            let fixWidth = size.height * 1080.0 / 1920.0;
            let fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRect(x: cropRect.origin.y/size.height,
                                    y: (cropRect.origin.x + fixPadding)/fixWidth,
                                    width: cropRect.size.height/size.height,
                                    height: cropRect.size.width/fixWidth)
        }
        return rectOfInterest
    }
    
    /// MARK - 获取Size
    private func getRetangeSize() -> CGSize {
        
        
        let xRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSize(width: self.frame.size.width - xRetangleLeft*2, height: self.frame.size.width - xRetangleLeft*2)
        
        let w = sizeRetangle.width
        var h = w / viewStyle.whRatio
        
        
        let hInt:Int = Int(h)
        h = CGFloat(hInt)
        
        sizeRetangle = CGSize(width: w, height:  h)
        
        return sizeRetangle
    }
    
    /// MARK - 设备开始准备
    public func deviceStartReadying(readyStr: String) {
        
        let xRetangleLeft = viewStyle.xScanRetangleOffset
        
        let sizeRetangle = getRetangeSize()
        
        /// 扫码区域Y轴最小坐标
        let yMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        
        
        self.activityView.center = CGPoint(x: xRetangleLeft +  sizeRetangle.width/2 - 50, y: yMinRetangle + sizeRetangle.height/2)
        self.addSubview(self.activityView)
        
        
        let labelReadyRect = CGRect(x: activityView.frame.origin.x + activityView.frame.size.width + 10, y: activityView.frame.origin.y, width: 100, height: 30);
        self.labelReadying.frame = labelReadyRect
        self.labelReadying.text = readyStr
        addSubview(labelReadying)
        activityView.startAnimating()
    }
    
    
    /// MARK - 设备停止准备
    public func deviceStopReadying() {
        
        activityView.stopAnimating()
        activityView.removeFromSuperview()
        labelReadying.removeFromSuperview()
    }
    
    
    /// MARK - 重载绘制
    override public func draw(_ rect: CGRect) {
        drawScanRect()
    }
    
    
    /// MARK - 绘制扫码效果
    private func drawScanRect() {
        
        let xRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSize(width: self.frame.size.width - xRetangleLeft * 2.0, height: self.frame.size.width - xRetangleLeft * 2.0)
        
        if viewStyle.whRatio != 1.0 {
            
            let w = sizeRetangle.width
            var h:CGFloat = w / viewStyle.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //扫码区域Y轴最小坐标
        let yMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let yMaxRetangle = yMinRetangle + sizeRetangle.height
        let xRetangleRight = self.frame.size.width - xRetangleLeft
        
        let context = UIGraphicsGetCurrentContext()!
        
        //非扫码区域半透明
        //设置非识别区域颜色
        context.setFillColor(viewStyle.notRecoginitonArea.cgColor)
        //填充矩形
        //扫码区域上面填充
        var rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: yMinRetangle)
        context.fill(rect)
        
        
        //扫码区域左边填充
        rect = CGRect(x: 0, y: yMinRetangle, width: xRetangleLeft, height: sizeRetangle.height)
        context.fill(rect)
        
        //扫码区域右边填充
        rect = CGRect(x: xRetangleRight, y: yMinRetangle, width: xRetangleLeft,height: sizeRetangle.height)
        context.fill(rect)
        
        //扫码区域下面填充
        rect = CGRect(x: 0, y: yMaxRetangle, width: self.frame.size.width,height: self.frame.size.height - yMaxRetangle)
        context.fill(rect)
        //执行绘画
        context.strokePath()
        
        
        if viewStyle.isNeedShowRetangle {
            
            //中间画矩形(正方形)
            context.setStrokeColor(viewStyle.colorRetangleLine.cgColor)
            context.setLineWidth(1);
            
            context.addRect(CGRect(x: xRetangleLeft, y: yMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height))
            
            context.strokePath()
        }
        
        scanRetangleRect = CGRect(x: xRetangleLeft, y:  yMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
        //画矩形框4格外围相框角
        
        //相框角的宽度和高度
        let wAngle = viewStyle.photoframeAngleW
        let hAngle = viewStyle.photoframeAngleH
        
        //4个角的 线的宽度
        let linewidthAngle = viewStyle.photoframeLineW // 经验参数：6和4
        
        //画扫码矩形以及周边半透明黑色坐标参数
        var diffAngle = linewidthAngle / 3
        
        switch viewStyle.photoframeAngleStyle {
        case .outer:
            //框外面4个角，与框紧密联系在一起
            diffAngle = linewidthAngle / 3
        case .on:
            //与矩形框重合
            diffAngle = 0
        case .inner:
            diffAngle = -viewStyle.photoframeLineW / 2
        }
        
        context.setStrokeColor(viewStyle.colorAngle.cgColor);
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        context.setLineWidth(linewidthAngle);
        
        
        // 位置
        let leftX = xRetangleLeft - diffAngle
        let topY = yMinRetangle - diffAngle
        let rightX = xRetangleRight + diffAngle
        let bottomY = yMaxRetangle + diffAngle
        
        //左上角水平线
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
        
        //左上角垂直线
        context.move(to: CGPoint(x: leftX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: topY+hAngle))
        
        //左下角水平线
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
        
        //左下角垂直线
        context.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))
        
        //右上角水平线
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))
        
        //右上角垂直线
        context.move(to: CGPoint(x: rightX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))
        
        //右下角水平线
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))
        
        //右下角垂直线
        context.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))
        
        context.strokePath()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    /// MARK - 释放
    deinit {
        debugPrint("释放ScanView")
        scanAnimation.stopAnimating()
    }
}
