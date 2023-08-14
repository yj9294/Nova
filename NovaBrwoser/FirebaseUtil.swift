//
//  FirebaseUtil.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/7/4.
//

import Foundation

class FirebaseUtil: NSObject {
    static func requestRemoteConfig() {
        // 获取本地配置
        if GADUtil.share.getConfig() == nil {
            let path = Bundle.main.path(forResource: "GADConfig", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            do {
                let data = try Data(contentsOf: url)
                let adConfig = try JSONDecoder().decode(ADConfig.self, from: data)
                GADUtil.share.updateConfig(adConfig)
                NSLog("[Config] Read local ad config success.")
            } catch let error {
                NSLog("[Config] Read local ad config fail.\(error.localizedDescription)")
            }
        }
        
        /// 广告配置是否是当天的
        if GADUtil.share.isNeedCleanLimit() {
            GADUtil.share.cleanLimit()
        }
    }
   
}


