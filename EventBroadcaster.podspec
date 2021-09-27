Pod::Spec.new do |spec|

  spec.name         = "EventBroadcaster"
  spec.version      = "1.0.3"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
This CocoaPods library for iOS, offering you event handling tools.
                   DESC

  spec.homepage     = "https://github.com/alisamaiee/EventBroadcaster-iOS"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Ali Samaiee" => "alisamaiee@live.com" }

  spec.ios.deployment_target = "9.0"
  spec.swift_version = "5.0"

  spec.source        = { :git => "https://github.com/alisamaiee/EventBroadcaster-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = "EventBroadcaster/EventBroadcaster/**/*.{h,m,swift}"
end