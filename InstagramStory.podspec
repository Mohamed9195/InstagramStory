#
#  Be sure to run `pod spec lint InstagramStory.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "InstagramStory"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of InstagramStory."
  spec.description    = "using push protocol to get any update in permissions when calling framework object one time, and can use Push RXPermission View to show all permission."
  spec.homepage       = "https://github.com/Mohamed9195/TRACKXY-TEST"
  spec.license        = "MIT"
  spec.author             = { "Mohamed Hashem" => "mohamedabdalwahab588@gmail.com" }
  spec.source         = { :git => "https://github.com/Mohamed9195/TRACKXY-TEST.git", :tag => "#{spec.version}" }
  spec.platform       = :ios, "12.0"
  spec.ios.deployment_target = "12.0"
  spec.source_files   = 'InstagramStory'
  spec.source_files   = 'InstagramStory/**/*.swift'
  spec.exclude_files  = "Classes/Exclude"
  spec.resources      = 'Resources/Info.plist'
  spec.resources      = "CTYCrashReporter/Assets/*"
  spec.resources      = "InstagramStory/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  spec.subspec 'App' do |app|
  app.source_files = 'TRACKXY/**/*.swift'
end

  spec.swift_version = "4.2"

end
