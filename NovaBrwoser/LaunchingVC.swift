//
//  ViewController.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/6/30.
//

import UIKit

class LaunchingVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var progress: Double = 0.0
    var duration: Double = 3.0
    var timer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        startLaunch()
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillEnterForground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func startLaunch() {
        progress = 0.0
        duration = 13.0
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(launching), userInfo: nil, repeats: true)
        GADUtil.share.load(.interstitial)
        GADUtil.share.load(.native)
    }
    
    @objc func launching() {
        progress += (0.01 / duration)
        if progress > 1.0 {
            timer?.invalidate()
            timer = nil
            GADUtil.share.show(.interstitial) { _ in
                if self.progress > 1.0 {
                    self.presentHome()
                }
            }
        } else {
            progressView.progress = Float(progress)
            if progress > 0.3, GADUtil.share.isLoadedIngerstitalAD(){
                duration = 0.1
            }
        }
    }
    
    func presentHome(){
        let vc = HomeVC.Load()
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.present(vc, animated: false)
        }
    }
    
    @objc func sceneWillEnterForground() {
        startLaunch()
    }
}

