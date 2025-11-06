# ``DebugKit``

Effortless Debug Menus for iOS Apps

## Overview

DebugKit is a lightweight but powerful tool to implement a Debug Menu in your app effortlessly.

## Setup

Initialize ``DebugMenuView`` as soon as the app starts.

#### SwiftUI

```swift
struct MyApp: App {
    init() {
        DebugMenuView.initialize()
    }
}
```

#### UIKit

```swift
@UIApplicationMain 
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DebugMenuView.initialize()
        return true
    }
}
```

### Register custom menu content

Alternatively, provide a custom complementary content for ``DebugMenuView`` to display below the proprietary sections.

Calling ``DebugMenuView/registerContent(_:)-fdls`` implicitly invokes ``DebugMenuView/initialize()`` as well.

```swift
struct MyApp: App {
    init() {
        DebugMenuView.registerContent { 
            LabeledContent("Time of day", value: Date.now, format: .dateTime.hour().minute().second())
        }
    }
}
```

---

## Present

Present ``DebugMenuView`` anywhere in the app using a one-line code.

```swift
Button("Present Debug Menu") {
    DebugMenuView.present()
}
```

### Present a component

Alternatively, present a component to present as an argument.

- SeeAlso: ``DebugMenuView/Component``

```swift
Button("Present Network Logs") {
    DebugMenuView.present(.networkLogs)
}
```

Notice that the debug menu itself is presented in fullscreen, but the nested components are presented as modal sheets.

### Presentation Mode

Define how the ``DebugMenuView`` transitions into view.

- SeeAlso: ``DebugMenuView/PresentationMode-swift.enum``

```swift
Picker("Presentation Mode", selection: $presentationMode) {
    ForEach(DebugMenuView.PresentationMode.allCases, id: \.self) { mode in
        Text(mode.description)
            .tag(mode)
    }
}
.onChange(of: presentationMode) { _, newValue in
    DebugMenuView.presentationMode = newValue
}
```

---

## Shake

Define what happens when the user shakes their device
by customizing the ``DebugMenuView/shakeMode-swift.type.property`` property. (iPhone only)

```swift
Picker("Shake Mode", selection: $shakeMode) {
    ForEach(DebugMenuView.ShakeMode.allCases, id: \.rawValue) { mode in
        Text(mode.description)
            .tag(mode)
    }
}
.onChange(of: shakeMode) { _, newValue in
    DebugMenuView.shakeMode = newValue
}
```

#### Disable Shake

If you only wish to present ``DebugMenuView`` programmatically,
you can set the ``DebugMenuView/shakeMode-swift.type.property`` property to ``DebugMenuView/ShakeMode-swift.enum/disabled``.

```swift
DebugMenuView.shakeMode = .disabled
```

## Topics

### Initialization

- ``DebugMenuView/initialize()``

### Presentation

- ``DebugMenuView``
- ``DebugMenuView/present()``

### Presenting A Nested Component

- ``DebugMenuView/present(_:)``
- ``DebugMenuView/Component``

### Registering Custom Content

- ``DebugMenuView/registerContent(_:)-fdls``
- ``DebugMenuView/registerContent(_:)-3yg69``

### Posting messages

- ``DebugMenuMessage``
- ``DebugMenuView/PostMessageCallback``

### Observing messages on a View

- ``SwiftUICore/View/onDebugMenuMessage(_:perform:)-3qicl``
- ``SwiftUICore/View/onDebugMenuMessage(_:perform:)-52i9v``
- ``SwiftUICore/EnvironmentValues/debugMenuMessage``

### Observing messages using Combine

- ``DebugMenuView/messagePublisher``
- ``DebugMenuView/onMessage(_:perform:)-6746m``
- ``DebugMenuView/onMessage(_:perform:)-9rdxn``

### Network Requests

- ``Foundation/URLSession/debug``
- ``Foundation/URLSessionConfiguration/debug``

### Notifications

- ``Foundation/NSNotification/Name/debugMenuMessage``
