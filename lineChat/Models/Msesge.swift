//
//  Msesge.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/17.
//

import Foundation
import Firebase
import FirebaseFirestore


class Msesge {
    
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    
    init(dic: [String: Any]) {
        self.name = dic["neme"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        
    }
}
