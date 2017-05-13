# RxStarscream
Rx support for Starscream

Extension for Starscream that offers support for RxSwift.

## Example:

### Listen for connection changes:

```
let disposeBag = DisposeBag()
connection.rx.connected.subscribe(onNext: { isConnected in
            if isConnected {
                print("Connected!")
            } else {
                print("Disconnected!")
            }
        }).addDisposableTo(disposeBag)
```

### Listen for incoming messages:

```
let disposeBag = DisposeBag()
connection.rx.text.subscribe(onNext: { text in
   print("Received: \(text)")
            
}).addDisposableTo(disposeBag)
```

### Send message

```
let disposeBag = DisposeBag()
self.connection.rx.send(text: "Hello world!").subscribe(onNext: {
    print("Sent!")
}).addDisposableTo(self.disposeBag)
```
