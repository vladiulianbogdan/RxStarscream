//
//  RxStarscream.swift
//
//  Created by Bogdan Vlad on 5/7/17.
//  Copyright © 2017 Bogdan Vlad. All rights reserved.
//

import RxSwift
import RxCocoa
import Starscream

public enum WebSocketEvent {
    case connected
    case disconnected(Error?)
    case message(String)
    case data(Data)
}

extension Reactive where Base: WebSocket {
    public var delegate: DelegateProxy {
        return RxWebSocketDelegateProxy.proxyForObject(base)
    }
    
    public var events: Observable<WebSocketEvent> {
        let proxy = RxWebSocketDelegateProxy.proxyForObject(base)
        return proxy.eventsSubject.asObserver()
    }
    
    public var text: Observable<String> {
        return events.filter { event -> Bool in
            switch (event) {
            case .message(_):
                return true
            default:
                return false
            }
        }.map { event -> String in
            switch(event) {
            case .message(let text):
                return text
            default:
                return ""
            }
        }
    }
    
    public var data: Observable<Data> {
        return events.filter { event -> Bool in
            switch (event) {
            case .data(_):
                return true
            default:
                return false
            }
        }.map { event -> Data in
            switch event {
            case .data(let data):
                return data
            default:
                return Data()
            }
        }
    }
    
    public var connected: Observable<Bool> {
        return events.filter { event -> Bool in
            switch event {
            case .connected, .disconnected(_):
                return true
            default:
                return false
            }
        }.map { event -> Bool in
            switch event {
            case .connected:
                return true
            case .disconnected(_):
                return false
            default:
                return false
            }
        }
    }
    
    public var disconnected: Observable<Error?> {
        return events.filter { event -> Bool in
            switch event {
            case .disconnected(_):
                return true
            default:
                return false
            }
        }.map { event -> Error? in
            switch event {
            case .disconnected(let error):
                return error
            default:
                return nil
            }
        }
    }
    
    func send(text: String) -> Observable<Void> {
        return Observable.create { subscriber -> Disposable in
            self.base.write(string: text, completion: { 
                subscriber.onNext()
                subscriber.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
    func send(data: Data) -> Observable<Void> {
        return Observable.create { subscriber -> Disposable in
            self.base.write(data: data, completion: { 
                subscriber.onNext()
                subscriber.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}

extension WebSocket {
    func createRxDelegateProxy() -> RxWebSocketDelegateProxy {
        return RxWebSocketDelegateProxy(parentObject: self)
    }
}

class RxWebSocketDelegateProxy: DelegateProxy,
                                WebSocketDelegate,
                                DelegateProxyType {
    
    public weak fileprivate(set) var webSocket: WebSocket?
    
    let eventsSubject = PublishSubject<WebSocketEvent>()
    
    required init(parentObject: AnyObject) {
        self.webSocket = Utils.castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }
    
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let webSocket: WebSocket = Utils.castOrFatalError(object)
        return webSocket.createRxDelegateProxy()
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let webSocket: WebSocket = Utils.castOrFatalError(object)
        webSocket.delegate = Utils.castOptionalOrFatalError(delegate)
    }
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let webSocket: WebSocket = Utils.castOrFatalError(object)
        return webSocket.delegate
    }
    
    func websocketDidConnect(socket: WebSocket) {
        eventsSubject.onNext(WebSocketEvent.connected)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        eventsSubject.onNext(WebSocketEvent.disconnected(error))
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        eventsSubject.onNext(WebSocketEvent.message(text))
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        eventsSubject.onNext(WebSocketEvent.data(data))
    }
}


