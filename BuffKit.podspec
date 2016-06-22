Pod::Spec.new do |s|

  s.name         = "BuffKit"
  s.version      = "0.11"
  s.author       = { "R4L" => "ralphwayne1991@gmail.com" }
  s.summary      = "BuffKit provides common features and functions in iOS development."
  s.description  = <<-DESC
			       BuffKit has provided data encryption/decryption,UIView"s frame access
			       ,CALayer"s frame accesss,geographic coordinate system transform(wgs84 to gcj02),
			       null handler(use method forwarding),split view etc.
                   DESC
  s.homepage     = "http://r4l.xyz"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.platform = :ios
  s.ios.deployment_target = "7.0"
  s.source = { :git => "https://github.com/FlashHand/BuffKit.git", :tag => "0.11" }
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto" }
  s.public_header_files = "BuffKit/*.h","BuffKit/**/*.h"
## s.source_files = "BuffKit/BuffKit.h","BuffKit/**/*.{h,m}"

  s.ios.frameworks   = "Foundation","UIKit","CoreLocation"
  s.requires_arc = true
end
