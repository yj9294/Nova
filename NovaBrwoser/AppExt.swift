//
//  AppExt.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/6/30.
//

import Foundation
import UIKit

struct UIViewControllerKey {
    static let rootVC = "rootVC"
    static let presentVC = "presentVC"
}

extension UIViewController {
    var rootVC: UIViewController {
        set {
            objc_setAssociatedObject(self, UIViewControllerKey.rootVC, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            (objc_getAssociatedObject(self, UIViewControllerKey.rootVC) as? UIViewController) ?? RootVC()
        }
    }
    
    var presentVC: UIViewController {
        set {
            objc_setAssociatedObject(self, UIViewControllerKey.presentVC, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            (objc_getAssociatedObject(self, UIViewControllerKey.presentVC) as? UIViewController) ?? PresentVC(vc: RootVC())
        }
    }
    
    private func RootVC() -> UIViewController {
        if let scene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let keyWindow = scene.keyWindow,  let rootVC = keyWindow.rootViewController {
                return rootVC
        }
        return UIViewController()
    }
    
    private func PresentVC(vc: UIViewController) -> UIViewController {
        if let  presentedVC = vc.presentedViewController {
            return PresentVC(vc: presentedVC)
        } else {
            return vc
        }
    }
}

extension UIViewController {
    
    static func Load() -> UIViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: .main)
        let vc = sb.instantiateViewController(withIdentifier: "\(Self.self)")
        vc.rootVC = vc.RootVC()
        vc.presentVC = vc.PresentVC(vc: vc.rootVC)
        return vc
    }
    
    func alert(_ message: String) {
        let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        self.presentVC.present(vc, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            vc.dismiss(animated: true)
        }
    }
}
