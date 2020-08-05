# 我主良缘二维码扫一扫组件

## Requirements:
- **iOS** 9.0+
- Xcode 9.0+
- Swift 5.0+


## Installation Cocoapods
<pre><code class="ruby language-ruby">pod 'WZScanQrcode', '~> 2.0.0'</code></pre>
<pre><code class="ruby language-ruby">pod 'WZScanQrcode/Binary', '~> 2.0.0'</code></pre>

## Framework
### 采用传统的MVC

``` M: 
M: WZPermissions(权限类), WZScanResult(扫描结果类), WZScanViewConfig(扫描View配置类)
V: WZScanAnimation(扫描动画View), WZScanView(扫描容器View), WZScanWrapper(扫码View)
C: WZScanViewController (扫码控制器)
```

## Usage
### 1. 支付宝扫一扫例子

``` swift
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
```

### 2. 微信扫一扫例子:

``` swift
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
```

### 3. 扫一扫结果回调 WZScanViewControllerDelegate:

``` js
func scanFinished(vc: WZScanViewController, scanResult: WZScanResult) {
        debugPrint("scanResult:\(scanResult)")
    }
```


## License
WZScanQrcode is released under an MIT license. See [LICENSE](LICENSE) for more information.
