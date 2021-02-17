# InstagramStory FrameWork


# Images
![simulator_screenshot_A766DE8A-8ECB-4C85-9D7D-C39C81D46113](https://user-images.githubusercontent.com/43496851/108180662-b92b4180-710f-11eb-86dd-fd33269a630d.png)

# authors     
 Mohamed Hashem mohamedabdalwahab588@gmail.com
 
# example
```swift

// you can Long Press on any sticker to remove it

import InstagramStory

 let storyboardBundle = Bundle(for: StoryViewController.self)
 let onBoardingStoryboard = UIStoryboard(name: "InstagramStoryBoard", bundle: storyboardBundle)
 let locationViewController = onBoardingStoryboard.instantiateInitialViewController()
 locationViewController?.modalPresentationStyle = .fullScreen
 if locationViewController != nil {
    self.present(locationViewController!, animated: true) {
        // write any code 
    }
 }

# additional

// add this in Info.plist
<plist version="1.0">
<string>any string</string>
</plist>

<plist version="1.0">
<string>any string</string>
</plist>

