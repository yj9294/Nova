//
//  PrivacyVC.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/7/4.
//

import UIKit

class PrivacyVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleButton: UIButton!
    var content: String = "" {
        didSet {
            textView.text = content
        }
    }
    var type: String = "" {
        didSet {
            titleButton.setTitle(type, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
    }
    
    @IBAction func back() {
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BrowserUtil.shared.webItem.webView.removeFromSuperview()
    }
}
