# ActorKit
Swift actor model experiments

Actor - Universal primitive of parallel execution. The actor model in computer science is a mathematical model of concurrent computation that treats "actors" as the universal primitives of concurrent computation. In response to a message that it receives, an actor can: make local decisions, create more actors, send more messages, and determine how to respond to the next message received. Actors may modify their own private state, but can only affect each other indirectly through messaging (obviating lock-based synchronization).

## Features

* Actor
* ActorUI
* Asynchronous invocations

## Useful Theory on Actors

- https://en.wikipedia.org/wiki/Actor_model

## Usage

#### Create Message

```swift
struct MyMessage: AKMessage {
    var text: String
}
```

#### Create Actor Subclass

```swift
class MyActor: Actor {
  override func onReceive(_ msg: AKMessage) {
    switch msg {
        case let msg as MyMessage:
            print(msg.text)
        default:
            unhandled(msg)
        }
  }
}
```
#### Create Actor in ActorSystem

```swift
let actorSystem = ActorSystem()
let actor = actorSystem.actorOf(MyActor.emptyProps(), name: "my-actor")
// and sending message
actor ! MyMessage(text: "this is my message")
```

## Author

Dmitriy Safarov, kazdevelop@gmail.com

## License

ActorKit is available under the MIT license

## Current Task List

- [ ] Actor Lifecycle
- [ ] Actors context correction
- [ ] Actor Watch
- [ ] Supervisor
- [ ] Error handling and processing
