//
//  WZScanViewConfig.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit
import Foundation



/// MARK - 扫码区域4个角位置类型
public enum WZScanViewPhotoframeAngleStyle {
    
    ///  内嵌,一般不显示矩形框情况下
    case inner
    
    ///  外嵌,包围在矩形框的4个角
    case outer
    
    ///  在矩形框的4个角上，覆盖
    case on
}


/// MARK - 扫码区域动画效果
public enum WZScanViewAnimationStyle {
    
    ///  无动画
    case none
    
    ///  线
    case line
    
    ///  网格
    case grid
}


/// MARK - 扫描View配置
public struct WZScanViewConfig {
    
    /// MARK - 是否需要绘制扫码矩形框，默认YES
    public var isNeedShowRetangle: Bool = true
    
    /// MARK - 默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
    public var whRatio: CGFloat = 1.0
    
    /// MARK - 动画时间默认1秒
    public var duration: TimeInterval = 1.0
    
    /// MARK - 矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，如果负值表示扫码区域下移
    public var centerUpOffset: CGFloat = 44
    
    /// MARK - 矩形框(视频显示透明区)域离界面左边及右边距离，默认60
    public var xScanRetangleOffset: CGFloat = 60
    
    /// MARK - 矩形框线条颜色,默认白色
    public var colorRetangleLine = UIColor.white
    
    /// MARK - 扫码区域的4个角类型
    public var photoframeAngleStyle = WZScanViewPhotoframeAngleStyle.outer
    
    /// MARK - 4个角的颜色
    public var colorAngle = UIColor(red: 0.0, green: 167.0/255.0, blue: 231.0/255.0, alpha: 1.0)
    
    /// MARK - 扫码区域4个角的宽度和高度
    public var photoframeAngleW: CGFloat = 24.0
    public var photoframeAngleH: CGFloat = 24.0
    
    /// MARK - 扫码区域4个角的线条宽度,默认6，建议8到4之间
    public var photoframeLineW: CGFloat = 6
    
    /// MARK - 扫码动画效果:线条或网格
    public var animationStyle = WZScanViewAnimationStyle.line
    
    /// MARK - 动画效果的图像,如线条或网格的图像
    public var animationImage: UIImage?
    
    /// MARK - 非识别区域颜色,默认 RGBA (0,0,0,0.5)，范围（0--1）
    public var notRecoginitonArea: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    
    /// 初始化
    public init() {
        
    }
}

