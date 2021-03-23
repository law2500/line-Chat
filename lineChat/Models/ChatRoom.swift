//
//  ChatRoom.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/17.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    let latestMessageId : String
    let menbers: [String]
    let createdAt: Timestamp
    
    var letestMssage: Msesge?
    var partnerUser: User?
    var documentId: String?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.menbers = dic["menbers"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        
    }
}
