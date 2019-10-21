#
#  Be sure to run `pod spec lint CXConsole.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "CXConsole"
  spec.version      = "1.0.0"
  spec.summary      = "iOS端日志悬浮窗"
  spec.platform     = :ios, "8.0"

  spec.description  = <<-DESC
  采用写入文件的方式将NSLog写入Cache文件内，并显示到手机上；方便测试查看。
                   DESC
  spec.homepage     = "https://github.com/gouzyi/CXLog.git"

  spec.license      = "MIT"
  spec.author             = { "zainguo" => "572249347@qq.com" }
  spec.source       = { :git => "https://github.com/gouzyi/CXLog.git", :tag => spec.version.to_s}

  spec.requires_arc = true

  spec.frameworks = 'Foundation', 'UIKit'

  spec.source_files  = "CXConsole", "CXConsole/**/*.{h,m}"

  spec.public_header_files = "CXConsole/**/*.h"

  spec.resources = "CXConsole/*.bundle"



end
