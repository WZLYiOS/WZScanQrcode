Pod::Spec.new do |s|

  s.name             = 'WZScanQrcode'
  s.version          = '2.0.2'
  s.summary          = 'WZScanQrcode 二维码扫一扫.'

  s.description      = <<-DESC
    模仿各种二维码扫一扫的Demo.
                       DESC

  s.homepage         = 'https://github.com/WZLYiOS/WZScanQrcode'
  s.license          = 'MIT'
  s.author           = { 'xiaobin liu'=> '327847390@qq.com' }
  s.source           = { :git => 'https://github.com/WZLYiOS/WZScanQrcode.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.static_framework = true
  s.swift_version         = '5.0'
  s.ios.deployment_target = '9.0'
  s.default_subspec = 'Source'

  s.subspec 'Source' do |ss|
    ss.source_files = 'WZScanQrcode/Classes/Controller/', "WZScanQrcode/Classes/Model/", "WZScanQrcode/Classes/View/",
    ss.frameworks = 'UIKit'
    ss.frameworks = 'Photos'
    ss.frameworks = 'Foundation'
    ss.frameworks = 'AVFoundation'
    ss.frameworks = 'AssetsLibrary'
  end


#  s.subspec 'Binary' do |ss|
#    ss.vendored_frameworks = "Carthage/Build/iOS/Static/WZScanQrcode.framework"
#    ss.user_target_xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)' }
#  end
end

