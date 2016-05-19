Pod::Spec.new do |s|

  s.name         = "BuffKit"
  s.version      = "0.11.7"
  s.author       = { "R4L" => "ralphwayne1991@gmail.com" }
  s.summary      = "BuffKit provides common features and functions in iOS development."
  s.description  = <<-DESC
			       BuffKit has provided data encryption/decryption,UIView"s frame access
			       ,CALayer"s frame accesss,geographic coordinate system transform(wgs84 to gcj02),
			       null handler(use method forwarding),file I/O,file zip/unzip,image processing etc.
                   DESC
  s.homepage     = "http://r4l.xyz"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.platform = :ios
  s.ios.deployment_target = "7.0"
  s.source = { :git => "https://github.com/FlashHand/BuffKit.git", :tag => "0.11.7" }
  s.public_header_files = "BuffKit/*.h","BuffKit/**/*.h"
  s.source_files = "BuffKit/*.{h,m}","BuffKit/**/*.{h,m}"

  s.ios.frameworks   = "Foundation","UIKit","CoreLocation"
  s.requires_arc = true
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto" }
	

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #




  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto" }
  # s.dependency "JSONKit", "~> 1.4"

end
