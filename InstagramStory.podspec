
Pod::Spec.new do |spec|

  spec.name         = "InstagramStory"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of InstagramStory."
  spec.description    = "using push protocol to get any update in permissions when calling framework object one time, and can use Push RXPermission View to show all permission."
  spec.homepage       = "https://github.com/Mohamed9195/InstagramStory"
  spec.license        = "MIT"
  spec.author             = { "Mohamed Hashem" => "mohamedabdalwahab588@gmail.com" }
  spec.source         = { :git => "https://github.com/Mohamed9195/InstagramStory.git", :tag => "#{spec.version}" }
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
