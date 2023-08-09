//
//  CleanVC.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/7/4.
//

import UIKit

class CleanVC: UIViewController {

    @IBOutlet weak var progressLabel: UILabel!
    var completion: (()->Void)? = nil
    
    var progress: Double = 0.0
    var duration: Double = 13.0
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BrowserUtil.shared.webItem.webView.removeFromSuperview()
    }
    
    func start() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer(timeInterval: 0.01, target: self, selector: #selector(cleanAnimation), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc func cleanAnimation() {
        progress += 0.01 / duration
        if progress > 1.0 {
            timer?.invalidate()
            self.back()
        } else {
            progressLabel.text = "\(Int(progress*100))%"
        }
    }
    
    func back() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            BrowserUtil.shared.clean(from: self)
            self.dismiss(animated: true){
                self.completion?()
            }
        }
    }

}
