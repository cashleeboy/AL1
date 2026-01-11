//
//  RotatableViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit

protocol RotatableViewController {
    var enterOrientation: ScreenRotator.Orientation { get }
}

extension RotatableViewController where Self: UIViewController {
    func applyOrientation() {
        ScreenRotator.shared.rotation(to: enterOrientation)
    }

    func resetOrientation() {
        ScreenRotator.shared.rotationToPortrait()
    }
}


//protocol PortraitOnlyViewController {}
//extension PortraitOnlyViewController where Self: UIViewController {
//    var supportedOrientations: UIInterfaceOrientationMask {
//        .portrait
//    }
//}
//
//extension UIViewController {
//    @objc open var supportedOrientations: UIInterfaceOrientationMask {
//        .all
//    }
//
//    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        supportedOrientations
//    }
//}
//
//protocol ForcePortrait {}
//extension ForcePortrait where Self: UIViewController {
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        .portrait
//    }
//}
