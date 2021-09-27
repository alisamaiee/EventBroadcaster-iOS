# EventBroadcaster-iOS
EventBroadcaster is a lightweight event handler written in swift for iOS, macOS, tvOS &amp; watchOS applications.

<img src="https://d29fhpw069ctt2.cloudfront.net/icon/image/120390/preview.svg?raw" width="300">

## Cocoapods
EventBroadcaster is available through [CocoaPods](http://cocoapods.org). Simply add the following to your Podfile:

```ruby
use_frameworks!

target '<Your Target Name>' do
  pod 'EventBroadcaster'
end
```

## How to use

* Import it to your project:
```swift
import EventBroadcaster
```

* Declare events: create a file in your project to implement an extension for EventBroadcaster class, to put event names there. (File name can be anything like "Events.swift")
In that file add events like this:
```swift
extension EventBroadcaster {
    static let DownloadCompleted = 0
    static let ConnectionLost = 1
    static let SettingsUpdated = 2
    static let AnyOtherEvent = 3
}
```
Make sure to set a unique event ID for each event.

* Setup observer: An event observer will receive updates from related events. Observer needs to implement EventBroadcasterDelegate methods:
```swift
extension ViewController: EventBroadcasterDelegate {
    func didReceivedNotification(_ id: Int, args: [Any]) {
        if id == EventBroadcaster.SettingsUpdated {
            // Cast expected arguments from args elements
            // For example, args[0] as? String or whatever
        } else if id == EventBroadcaster.DownloadCompleted {
            // Do whatever you want
        }
    }
}
```
* Add observer:
Now your ViewController (or any other class that you need) is ready to observe for events. So add it as observer to events that it needs: (You can do it in init() or wherever you want)
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    do {
        EventBroadcaster.sharedInstance.addObserver(self, EventBroadcaster.SettingsUpdated)
        EventBroadcaster.sharedInstance.addObserver(self, EventBroadcaster.DownloadCompleted)
    } catch {
        print(error)
    }
}
```
* Broadcast event: Anyone from anywhere can broadcast any event; for example your DownloadManager wants to broadcast that a file download completed:
```swift
EventBroadcaster.sharedInstance.broadcastEvent(EventBroadcaster.DownloadCompleted, [fileID, fileSize])
```
 * Remove observer: Since EventBroadcaster holds a weak refrence of observer, you don't need to worry about memory leak but we've got an emergancy method to make sure that the observer is refrence is removed. Also you can use it when you want to stop listening to an event updates.
 ```swift
deinit {
    try? EventBroadcaster.sharedInstance.removeObserver(self, EventBroadcaster.SettingsUpdated)
    try? EventBroadcaster.sharedInstance.removeObserver(self, EventBroadcaster.DownloadCompleted)
}
```

### Advanced:
* Sometimes for any reason, you want your broadcaster to stop broadcasting for a while and keep updates until you want it to flush them; For example I stop broadcasting while my app is performing an animation because I don't want my animation lagging (It is possible to have many events at the moment). EventBroadcaster guarantees to stack your events by their orders when you tell it there is an animation, and flush them all when you tell it the animation is completed:
```swift
EventBroadcaster.sharedInstance.setAnimationInProgress(value: true)
// Animation
EventBroadcaster.sharedInstance.setAnimationInProgress(value: false)
```
