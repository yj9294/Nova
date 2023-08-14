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

let AppUrl = "https://itunes.apple.com/cn/app/id"

class HomeVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var searchBUtton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bootomCollection: UICollectionView!
    
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var cleanAlertView: UIView!
    
    @IBOutlet weak var adView: GADNativeView!
    var viewAppear: Bool = false
    var adImpressionTime = Date(timeIntervalSinceNow: -11)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "#AF82FF")?.cgColor
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNativeAD), name: .nativeUpdate, object: nil)
    }
    
    @objc func receiveNativeAD(noti: Notification) {
        if viewAppear {
            if adImpressionTime.timeIntervalSinceNow < -10 {
                adImpressionTime = Date()
                if let ad = noti.object as? NativeADModel {
                    adView.nativeAd = ad.nativeAd
                }
                return
            }
            adView.nativeAd = .none
            NSLog("[ad] 10s home 原生广告刷新或数据填充间隔.")
        }
        
    }

    func refreshStatus() {
        progressView.progress = BrowserUtil.shared.progress()
        progressView.isHidden = !BrowserUtil.shared.isLoading()
        textField.text = BrowserUtil.shared.url()
        searchBUtton.isSelected = BrowserUtil.shared.isLoading()
        bootomCollection.reloadData()
        var date = Date()
        if BrowserUtil.shared.progress() == 0.1 {
            date = Date()
            FirebaseUtil.log(event: .webStart)
        }
        if BrowserUtil.shared.progress() == 1.0 {
            let time = ceil(abs(date.timeIntervalSinceNow))
            FirebaseUtil.log(event: .webSuccess, params: ["bro": "\(time)"])
        }
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
        viewAppear = true
        IQKeyboardManager.shared.enable = true
        refreshStatus()
        addObserver()
        FirebaseUtil.log(event: .homeShow)
        ATTrackingManager.requestTrackingAuthorization { _ in
        }
        GADUtil.share.load(.native)
        GADUtil.share.load(.interstitial)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewAppear = false
        GADUtil.share.disappear(.native)
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
            FirebaseUtil.log(event: .search, params: ["bro": textField.text!])
        }
        searchBUtton.isSelected = !searchBUtton.isSelected
    }
    
    func search() {
        view.endEditing(true)
        BrowserUtil.shared.load(textField.text!, from:self)
    }
    
    func showClanAlert() {
        presentCleanAlertView()
        FirebaseUtil.log(event: .cleanClick)
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
                FirebaseUtil.log(event: .cleanSuccess)
                self.refreshStatus()
                self.alert("Cleaned.")
                FirebaseUtil.log(event: .cleanAlert)
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
        FirebaseUtil.log(event: .tabNew, params: ["bro": "setting"])
    }
    
    @IBAction func shareAction() {
        var url = AppUrl
        if !BrowserUtil.shared.webItem.isNavigation {
            url = BrowserUtil.shared.webItem.webView.url?.absoluteString ?? AppUrl
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
        dismissSettingView()
        FirebaseUtil.log(event: .shareClick)
    }
    
    @IBAction func copyAction() {
        dismissSettingView()
        FirebaseUtil.log(event: .copyClick)
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
The following terms and conditions (the “Terms”) govern your use of the VPN services we provide (the “Service”) and their associated website domains (the “Site”). These Terms constitute a legally binding agreement (the “Agreement”) between you and Tap VPN. (the “Tap VPN”).

Activation of your account constitutes your agreement to be bound by the Terms and a representation that you are at least eighteen (18) years of age, and that the registration information you have provided is accurate and complete.

Tap VPN may update the Terms from time to time without notice. Any changes in the Terms will be incorporated into a revised Agreement that we will post on the Site. Unless otherwise specified, such changes shall be effective when they are posted. If we make material changes to these Terms, we will aim to notify you via email or when you log in at our Site.

By using Tap VPN
You agree to comply with all applicable laws and regulations in connection with your use of this service.regulations in connection with your use of this service.
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
The following terms and conditions (the “Terms”) govern your use of the VPN services we provide (the “Service”) and their associated website domains (the “Site”). These Terms constitute a legally binding agreement (the “Agreement”) between you and Tap VPN. (the “Tap VPN”).

Activation of your account constitutes your agreement to be bound by the Terms and a representation that you are at least eighteen (18) years of age, and that the registration information you have provided is accurate and complete.

Tap VPN may update the Terms from time to time without notice. Any changes in the Terms will be incorporated into a revised Agreement that we will post on the Site. Unless otherwise specified, such changes shall be effective when they are posted. If we make material changes to these Terms, we will aim to notify you via email or when you log in at our Site.

By using Tap VPN
You agree to comply with all applicable laws and regulations in connection with your use of this service.regulations in connection with your use of this service.
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
        FirebaseUtil.log(event: .fbClick, params: ["bro": HomeItem.allCases[indexPath.row].rawValue])
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
