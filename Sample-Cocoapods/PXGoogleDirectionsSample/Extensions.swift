//
//  Extensions.swift
//  PXGoogleDirectionsSample
//
//  Created by Andrea Stevanato on 23/04/2018.
//  Copyright © 2018 RLT. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
