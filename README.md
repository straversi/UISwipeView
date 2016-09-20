# UISwipeView

The main file is ./UISwipeView/UISwipeView.swift

### Dependency

* [Cartography](https://github.com/robb/Cartography)

*Disclaimer*: Custom views can be initialized differently if you're using storyboard or not. Until I've documented each use, some experience may help with setting up your specific case.

## Get going

### Programmatic

Initialize a UISwipeView in viewDidLoad:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    let contentViews = [view1, view2, ...]
    let swipeView = UISwipeView(subviews: contentViews)
    self.view.addSubview(swipeView)
    constrain(swipeView) { swipe in
        // constrain swipeView (this example uses Cartography)
    }
    swipeView.swipeDidEnd = { chartIndex in
        // do something with currentIndex if you'd like
    }
}
```

### Storyboard

To initialize a UISwipeView, prepare an outlet to a UISwipeView.

```swift
@IBOutlet weak var swipeView: UISwipeView!
```

Then, in viewDidAppear:

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
