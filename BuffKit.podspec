Pod::Spec.new do |spec|
  spec.name         = "BuffKit"
  spec.version      = "0.1"
  spec.author       = { "R4L" => "ralphwayne1991@gmail.com" }
  spec.summary      = "BuffKit provides common features and functions in iOS development."
  spec.description  = <<-DESC
			       BuffKit has provided data encryption/decryption,UIView"s frame access
			       ,CALayer"s frame accesss,geographic coordinate system transform(wgs84 to gcj02),
			       null handler(use method forwarding),file I/O,file zip/unzip,image processing etc.
                   DESC
  spec.homepage     = "http://r4l.xyz"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.platform = :ios
  spec.ios.deployment_target = "7.0"
  spec.source = { :git => "https://github.com/FlashHand/BuffKit.git", :tag => "0.1" }
  spec.public_header_files = 'BuffKit/BuffKit.h'
  spec.source_files = "BuffKit/BuffKit.h"

  spec.frameworks   = "Foundation","UIKit","CoreLocation"
  spec.requires_arc = true
end