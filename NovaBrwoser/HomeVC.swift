//
//  HomeVC.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/6/30.
//

import WebKit
import UIKit
import AppTrackingTransparency
import IQKeyboardManagerSwift
import UniformTypeIdentifiers

let AppUrl = "https://itunes.apple.com/cn/app/id6458101346"

class HomeVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var searchBUtton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bootomCollection: UICollectionView!
    
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var cleanAlertView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "#AF82FF")?.cgColor
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
    }


    func refreshStatus() {
        progressView.progress = BrowserUtil.shared.progress()
        progressView.isHidden = !BrowserUtil.shared.isLoading()
        textField.text = BrowserUtil.shared.url()
        searchBUtton.isSelected = BrowserUtil.shared.isLoading()
        bootomCollection.reloadData()
    }
    
    func addObserver() {
        if !BrowserUtil.shared.isNavigation(), BrowserUtil.shared.url().count != 0 {
            BrowserUtil.shared.webItem.webView.removeFromSuperview()
            view.addSubview(BrowserUtil.shared.webItem.webView)
            BrowserUtil.shared.webItem.webView.navigationDelegate = self
            BrowserUtil.shared.webItem.webView.uiDelegate = self
        }
        BrowserUtil.shared.webItem.webView.navigationDelegate = self
        BrowserUtil.shared.webItem.webView.uiDelegate = self
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        refreshStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        refreshStatus()
        addObserver()
        ATTrackingManager.requestTrackingAuthorization { _ in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        BrowserUtil.shared.webItem.webView.frame = contentView.frame
        settingView.frame = view.bounds
    }
}

extension HomeVC {
    
    @IBAction func searchAction() {
        view.endEditing(true)
        if searchBUtton.isSelected {
            textField.text = ""
            BrowserUtil.shared.stopLoad()
        } else {
            if textField.text == nil || textField.text?.count == 0 {
                alert("Please enter your search content.")
                return
            }
            search()
        }
        searchBUtton.isSelected = !searchBUtton.isSelected
    }
    
    func search() {
        view.endEditing(true)
        BrowserUtil.shared.load(textField.text!, from:self)
    }
    
    func showClanAlert() {
        presentCleanAlertView()
    }
    
    func showTab() {
        let vc = TabVC.Load()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func showSetting(){
        presentSettingView()
    }
    
    @IBAction func showClean() {
        dismissCleanAlertView()
        let vc = CleanVC.Load()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        if let vc = vc as? CleanVC {
            vc.completion = {
                self.refreshStatus()
                self.alert("Cleaned.")
            }
        }
    }
    
    func presentCleanAlertView() {
        view.addSubview(cleanAlertView)
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanAlertView.alpha = 1.0
        }
    }
    
    @IBAction func dismissCleanAlertView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.cleanAlertView.alpha = 0.0
        }
    }
    
    func presentSettingView() {
        view.addSubview(settingView)
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.settingView.alpha = 1.0
        }
    }
    
    @IBAction func dismissSettingView() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.settingView.alpha = 0.0
        }
    }
    
    @IBAction func addAction() {
        BrowserUtil.shared.add()
        refreshStatus()
        dismissSettingView()
    }
    
    @IBAction func shareAction() {
        var url = AppUrl
        if !BrowserUtil.shared.webItem.isNavigation {
            url = BrowserUtil.shared.webItem.webView.url?.absoluteString ?? AppUrl
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
        dismissSettingView()
    }
    
    @IBAction func copyAction() {
        dismissSettingView()
        if !BrowserUtil.shared.webItem.isNavigation {
            UIPasteboard.general.setValue(BrowserUtil.shared.webItem.webView.url?.absoluteString ?? "", forPasteboardType: UTType.plainText.identifier)
            self.alert("Copied.")
            return
        }
        UIPasteboard.general.setValue("", forPasteboardType: UTType.plainText.identifier)
        alert("Copied.")
    }
    
    @IBAction func rateAction() {
        dismissSettingView()
        let url = URL(string: AppUrl)
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func privacyAction() {
        dismissSettingView()
        let vc = PrivacyVC.Load()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        if let vc = vc as? PrivacyVC {
            vc.type = "Privacy Policy"
            vc.content = """
Privacy Policy

If you decide to use our services, then this page will inform you of our policies regarding the collection, use, and disclosure of personal information.

If you choose to use our services, you agree to our collection and use of information related to this policy. The personal information we collect will be used to provide and improve services, and we will not use or share your information with anyone except as described in this privacy policy.

Information Collection and Use

For a better experience, when using our apps, we may ask you to provide us with certain personally identifiable information. The information we request will be retained by us and used in accordance with this Privacy Policy.

The app does use third-party services that may collect information used to identify you. These third parties need to know how you interact with the ads served in the app, which helps us keep the app's cost free. Advertisers and AD networks use some of the information collected by the app, including but not limited to your mobile device's unique identification ID and your location.

How we share information

For the following reasons, we may engage third party companies to promote our services, provide services on our behalf, perform services related to our Services, or help us analyze how to use our Services.

Update

We may make changes to this Privacy Policy at our sole discretion and indicate the date of the last change. If you need to know about updates to our Privacy policy, you can often click here. We reserve the right to send you an email notifying you of substantial changes, and previous versions will be available from this page.

Contact us

If you have any questions about this policy, you can contact our support team via the email below.

kyle02132@gmail.com


Terms of use

Use of the application

1. You agree that we will use your information for the purposes required by laws and regulations.

2. You acknowledge that you may not use our App for illegal purposes.

3. You agree that we may discontinue providing our products and services at any time without prior notice.

4. By agreeing to download or install our software, you accept our Privacy Policy.

Update

We may make changes to this Privacy Policy at our sole discretion and indicate the date of the last change. If you need to know about updates to our Privacy policy, you can often click here. We reserve the right to send you an email notifying you of substantial changes, and previous versions will be available from this page.

Contact us

If you have any questions about this policy, you can contact our support team via the email below.

kyle02132@gmail.com
"""
        }
    }
    
    @IBAction func termsAction() {
        dismissSettingView()
        let vc = PrivacyVC.Load()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        if let vc = vc as? PrivacyVC {
            vc.type = "Terms of Users"
            vc.content = """
Terms of use
Use of the application
1. You agree that we will use your information for the purposes required by laws and regulations.
2. You acknowledge that you may not use our App for illegal purposes.
3. You agree that we may discontinue providing our products and services at any time without prior notice.
4. By agreeing to download or install our software, you accept our Privacy Policy.
Update
We may make changes to this Privacy Policy at our sole discretion and indicate the date of the last change. If you need to know about updates to our Privacy policy, you can often click here. We reserve the right to send you an email notifying you of substantial changes, and previous versions will be available from this page.
Contact us
If you have any questions about this policy, you can contact our support team via the email below.
kyle02132@gmail.com
"""
        }

    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bootomCollection {
            return HomeBottomItem.allCases.count
        }
        return HomeItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemCell", for: indexPath)
        if let cell = cell as? HomeItemCell {
            if collectionView == bootomCollection {
                cell.bottomItem = HomeBottomItem.allCases[indexPath.row]
            } else {
                cell.item = HomeItem.allCases[indexPath.row]
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bootomCollection {
            return 0.0
        }
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bootomCollection {
            return 0.0
        }
        return 40.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bootomCollection {
            let width = view.bounds.width / 5.0
            return CGSize(width: width, height: 66)
        }
        let width = (view.bounds.width - 60 - 40*3) / 4.0 - 2
        let height = 62.0
        return CGSizeMake(width, height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bootomCollection {
            switch HomeBottomItem.allCases[indexPath.row] {
            case .last:
                BrowserUtil.shared.goBack()
            case .next:
                BrowserUtil.shared.goForword()
            case .clean:
                showClanAlert()
            case.tab:
                showTab()
            case .setting:
                showSetting()
            }
            return
        }
        textField.text = HomeItem.allCases[indexPath.row].url
        search()
    }
}

extension HomeVC: WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate {
    /// 跳转链接前是否允许请求url
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        bootomCollection.reloadData()
        return .allow
    }
    
    /// 响应后是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        bootomCollection.reloadData()
        return .allow
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /// 打开新的窗口
        bootomCollection.reloadData()
        webView.load(navigationAction.request)
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}


class HomeItemCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    var item: HomeItem? = nil {
        didSet{
            icon.image = item?.icon
            title.text = item?.title
        }
    }
    var bottomItem: HomeBottomItem? = nil {
        didSet {
            icon.image = bottomItem?.icon
            if bottomItem == .tab {
                title.text = "\(BrowserUtil.shared.webItems.count)"
            } else {
                title.text = ""
            }
        }
    }
}


enum HomeItem: String, CaseIterable {
    case facebook, google, youtube, twitter, instagram, amazon, tiktok, yahoo
    var title: String {
        self.rawValue.capitalized
    }
    var icon: UIImage {
        UIImage(named: self.rawValue) ?? UIImage()
    }
    var url: String {
        "https://www.\(self.rawValue).com"
    }
}

enum HomeBottomItem: String, CaseIterable {
    case last, next, clean, tab, setting
    var icon: UIImage {
        if !BrowserUtil.shared.canGoBack(), self == .last {
            return UIImage(named: "last_1") ?? UIImage()
        }
        if !BrowserUtil.shared.canGoForword(), self == .next {
            return UIImage(named: "next_1") ?? UIImage()
        }
        return UIImage(named: self.rawValue) ?? UIImage()
    }
}
