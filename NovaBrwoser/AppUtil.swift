//
//  AppUtil.swift
//  NovaBrwoser
//
//  Created by yangjian on 2023/6/30.
//

import Foundation

extension String {
    func isUrl() -> Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}
