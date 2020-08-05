//
//  WZScanAnimation.swift
//  WZScanQrcode
//
//  Created by xiaobin liu on 2019/7/6.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

import UIKit

/// MARK - 扫描动画View
final class WZScanAnimation: UIImageView {
    
    /// MARK - 是否正在动画
    public var isAnimationing = false
    
    /// MARK - 动画位置
    public var animationRect: CGRect = CGRect.zero
    
    /// MARK - 动画时间
    public var duration: TimeInterval = 1.0
    
    /// MARK - 动画风格
    public var animationStyle: WZScanViewAnimationStyle = .none
    
    
    /// MARK - 开始动画
    public override func startAnimating() {
        
        if image != nil && animationStyle != .none {
            isAnimationing = true
            stepAnimation()
        }
    }
    
    
    /// MARK - 配置动画
    @objc private func stepAnimation() {
        
        if isAnimationing == false {
            return
        }
        
        switch animationStyle {
        case .line:
            lineAnimation()
        case .grid:
            gridAnimation()
        default:
            break
        }
    }
    
    /// MARK - 线的动画
    private func lineAnimation() {
        
        var frame: CGRect = animationRect
        let hImg = image!.size.height * animationRect.size.width / image!.size.width
        
        frame.origin.y = frame.origin.y - hImg + hImg / 2
        frame.size.height = hImg
        self.frame = frame
        
        UIView.animate(withDuration: self.duration, animations: { [weak self] in
            
            guard let self = self else { return }
            
            var frame = self.animationRect
            frame.origin.y = frame.origin.y + (frame.size.height -  hImg + hImg / 2 - 4)
            frame.size.height = hImg
            self.frame = frame
            
            }, completion:{ [weak self] (value) -> Void in
                
                guard let self = self else { return }
                self.perform(#selector(WZScanAnimation.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    
    /// MARK - 网格动画
    private func gridAnimation() {
        
        var frame: CGRect = animationRect
        let hImg = image!.size.height * animationRect.size.width / image!.size.width
        
        frame.size.height = 0
        self.frame = frame
        
        UIView.animate(withDuration: self.duration, animations: { [weak self] in
            
            guard let self = self else { return }
            
            var frame = self.animationRect
            frame.size.height = hImg + 2
            self.frame = frame
            
            }, completion: { [weak self] _ in
                
                guard let self = self else { return }
                self.perform(#selector(WZScanAnimation.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    
    
    /// MARK - 停止动画
    public override func stopAnimating() {
        isAnimationing = false
    }
    
    
    /// MARK - 释放
    deinit {
        debugPrint("释放ScanAnimation")
        stopAnimating()
    }
}

