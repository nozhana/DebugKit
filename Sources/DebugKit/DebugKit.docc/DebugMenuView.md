# ``DebugMenuView``

## Present

Present `DebugMenuView` using a simple function call.

```swift
DebugMenuView.present()
```

### Present a component

Present a nested component as a modal sheet using ``DebugMenuView/present(_:)``.

```swift
DebugMenuView.present(.databaseLogs)
```

---

## Custom content

Register custom menu content to display below the proprietary content.

```swift
DebugMenuView.registerContent {
    Text("Copyright Nozhan Amiri © 2025")
}
```

### Post messages

Since you cannot capture state variables or a mutating view inside the ``DebugMenuView/registerContent(_:)-fdls`` callback,
you can post a ``DebugMenuMessage`` from inside the complementary content and receive it on a view.

```swift
DebugMenuView.registerContent { post in
    Text("Copyright Nozhan Amiri © 2025")
    Button("Clear logs") {
        post(.clearLogs)
    }
}

extension DebugMenuMessage {
    static let clearLogs: DebugMenuMessage = "clearLogs"
}
```

### Observe messages

Now to receive it on a view, you can use the convenience ``SwiftUICore/View/onDebugMenuMessage(_:perform:)-(_,()->Void)`` modifier.

```swift
var body: some View {
    MyView()
        .onDebugMenuMessage(.clearLogs) {
            model.clearLogs()
        }
}
```

Or receive it using the Combine framework and either via the ``DebugMenuView/messagePublisher``
or by invoking ``DebugMenuView/onMessage(_:perform:)-6746m``.

```swift
@MainActor func setupBindings() {
    // Observe a specific message
    DebugMenuView
        .onMessage(.clearLogs) { [weak self] in
            self?.clearLogs()
        }
        .store(in: &cancellables)

    // Observe all messages
    DebugMenuView
        .onMessage {
            print("Debug menu message received!")
        }
        .store(in: &cancellables)

    DebugMenuView.messagePublisher
        .sink { [weak self] message in 
            self?.handleMessage(message)
        }
        .store(in: &cancellables)
}
```

## Topics

### Initialization

- ``DebugMenuView/initialize()``

### Custom content

- ``DebugMenuView/Content``
- ``DebugMenuView/registerContent(_:)-fdls``
- ``DebugMenuView/registerContent(_:)-(()->View)``

### Messages

- ``DebugMenuView/PostMessageCallback``
- ``DebugMenuView/messagePublisher``
- ``DebugMenuView/onMessage(_:perform:)-9rdxn``
- ``DebugMenuView/onMessage(_:perform:)-6746m``

### Presentation

- ``DebugMenuView/present()``
- ``DebugMenuView/present(_:)``
- ``DebugMenuView/Component``
- ``DebugMenuView/PresentationMode-swift.enum``
- ``DebugMenuView/presentationMode-swift.type.property``

### Shake

- ``DebugMenuView/ShakeMode-swift.enum``
- ``DebugMenuView/shakeMode-swift.type.property``

### View Conformance

- ``DebugMenuView/init()``
- ``DebugMenuView/body``
