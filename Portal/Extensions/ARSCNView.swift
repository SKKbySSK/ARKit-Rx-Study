//
//  ARSCNView.swift
//  Portal
//
//  Created by 砂賀開晴 on 2019/06/12.
//  Copyright © 2019 Kaisei Sunaga. All rights reserved.
//

import Foundation
import ARKit
import RxSwift
import RxCocoa

extension ARSCNView: HasDelegate {
    public typealias Delegate = ARSCNViewDelegate
}

enum ARSessionInterruptionState {
    case began
    case ended
}

class RxARSCNViewDelegateProxy: DelegateProxy<ARSCNView, ARSCNViewDelegate>, ARSCNViewDelegate, DelegateProxyType {
    public static func registerKnownImplementations() {
        register(make: { RxARSCNViewDelegateProxy(arScnView: $0) })
    }
    
    public init(arScnView: ARSCNView) {
        super.init(parentObject: arScnView, delegateProxy: RxARSCNViewDelegateProxy.self)
    }
    
    internal lazy var onSessionInterruptionStateChanged = PublishSubject<ARSessionInterruptionState>()
    internal lazy var onTrackingStateChanged = PublishSubject<ARCamera>()
    
    func sessionWasInterrupted(_ session: ARSession) {
        onSessionInterruptionStateChanged.onNext(.began)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        onSessionInterruptionStateChanged.onNext(.ended)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        onTrackingStateChanged.onNext(camera)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        onTrackingStateChanged.onError(error)
    }
    
    deinit {
        onSessionInterruptionStateChanged.onCompleted()
    }
}

extension Reactive where Base: ARSCNView {
    private var proxy: RxARSCNViewDelegateProxy {
        return RxARSCNViewDelegateProxy.proxy(for: base)
    }
    
    public var delegate: DelegateProxy<ARSCNView, ARSCNViewDelegate> {
        return proxy
    }
    
    var interruptionStateChanged: Observable<ARSessionInterruptionState> {
        return proxy.onSessionInterruptionStateChanged.asObservable()
    }
    
    var trackingStateChanged: Observable<ARCamera> {
        return proxy.onTrackingStateChanged.asObservable()
    }
}
