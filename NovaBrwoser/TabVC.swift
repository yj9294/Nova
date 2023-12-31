//
//  TabVC.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/7/4.
//

import UIKit

class TabVC: UIViewController {
    
    @IBOutlet weak var adView: GADNativeView!
    var viewAppear: Bool = false
    var adImpressionTime: Date {
        GADUtil.share.tabNativeAdImpressionDate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNativeAD), name: .nativeUpdate, object: nil)
    }
    
    @objc func receiveNativeAD(noti: Notification) {
        if viewAppear {
            if adImpressionTime.timeIntervalSinceNow < -10 {
                GADUtil.share.tabNativeAdImpressionDate = Date()
                if let ad = noti.object as? NativeADModel, ad.nativeAd != nil {
                    adView.nativeAd = ad.nativeAd
                }
                return
            }
            NSLog("[ad] 10s tab 原生广告刷新或数据填充间隔.")
        }
    }
    
    @IBAction func add() {
        BrowserUtil.shared.add()
        self.dismiss(animated: true)
    }
    
    @IBAction func back() {
        self.dismiss(animated: true)
    }
    
    func delete(_ item: WebViewItem, in collectionView: UICollectionView) {
        BrowserUtil.shared.removeItem(item)
        collectionView.reloadData()
    }
    
    func select(_ item: WebViewItem) {
        BrowserUtil.shared.select(item)
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BrowserUtil.shared.webItem.webView.removeFromSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewAppear = true
        GADUtil.share.load(.native)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewAppear = false
        super.viewWillDisappear(animated)
        GADUtil.share.disappear(.native)
    }
}

extension TabVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        BrowserUtil.shared.webItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath)
        if let cell = cell as? TabCell {
            let item = BrowserUtil.shared.webItems[indexPath.row]
            cell.item = item
            cell.deleteHandle = { [weak self] in
                self?.delete(item, in: collectionView)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 32 - 16) / 2.0 - 3
        let height = 224.0 / 156.0 * width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = BrowserUtil.shared.webItems[indexPath.row]
        select(item)
    }
    
}

class TabCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var deleteHandle: (()->Void)? = nil
    
    var item: WebViewItem? {
        didSet {
            label.text = item?.webView.url?.absoluteString
            if BrowserUtil.shared.webItems.count == 1 {
                self.closeButton.isHidden = true
            } else {
                self.closeButton.isHidden = false
            }
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
            contentView.layer.borderWidth = item?.isSelect == true ? 1 : 0
            contentView.layer.borderColor = UIColor(named: "#AF82FF")?.cgColor
        }
    }
    
    @IBAction func close() {
        deleteHandle?()
    }
}
