//
//  AlertExtensions.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

extension UIViewController {
    class func getCurrentVC() -> UIViewController? {
        var result: UIViewController?
        var window = UIApplication.shared.windows.first { $0.isKeyWindow }
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        let fromView = window?.subviews[0]
        if let nextRespnder = fromView?.next {
            if nextRespnder.isKind(of: UIViewController.self) {
                result = nextRespnder as? UIViewController
                result?.navigationController?.pushViewController(result!, animated: false)
            } else {
                result = window?.rootViewController
            }
        }
        return result
    }
}

extension UIAlertController {
    //Setting our Alert ViewController, presenting it.
    func presentAlert() {
        UIViewController.getCurrentVC()?.present(self, animated: true, completion: nil)
    }

    func dismissAlert() {
        UIViewController.getCurrentVC()?.dismiss(animated: true, completion: nil)
    }
}
