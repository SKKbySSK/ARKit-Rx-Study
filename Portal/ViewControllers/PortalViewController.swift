//
//  PortalViewController.swift
//  Portal
//
//  Created by 砂賀開晴 on 2019/06/12.
//  Copyright © 2019 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ARKit
import PortalMask

class PortalViewController: UIViewController {
    @IBOutlet weak var arView: ARSCNView!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        arView.rx.trackingStateChanged.subscribe({ print($0) }).disposed(by: bag)
    }
}
