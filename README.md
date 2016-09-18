# UISwipeView

## Setup

The main file is ./UISwipeView/UISwipeView.swift

### Dependency

* [Cartography](https://github.com/robb/Cartography)

*Disclaimer*: Custom views can be initialized differently if you're using storyboard or not. Until I've documented each use, some experience may help with setting up your specific case.

To initialize a UISwipeView, prepare an outlet to a UISwipeView, or create the view programatically.

```swift
@IBOutlet weak var swipeView: UISwipeView!
```

Then, in viewDidAppear (or viewDidLoad if you created UISwipeView with bounds programatically):

```swift
override func viewDidAppear(animated: Bool) {
    // Check if swipeView has already been initialized, if bounds were set with storyboard
    if swipeView.subViewContents.count == 0 {
        swipeView.initFromNibWithSubviews([view1, view2, ...])
        swipeView.goTo(someIndex)
        
        // Setup up callback for after a swipe is completed
        swipeView.swipeDidEnd = { currentIndex in
            // do something with currentIndex if you'd like
        }
    }
    super.viewDidAppear(animated)
}
```
