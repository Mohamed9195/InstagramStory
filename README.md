# InstagramStory FrameWork


# Images
![Simulator Screen Shot - iPhone 11 Pro Max - 2022-05-15 at 12 23 30](https://user-images.githubusercontent.com/43496851/168468153-9a659ccf-097e-402c-8387-a6038ab83489.png)


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

