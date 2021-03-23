//
//  User.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/16.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore


class User {
    
    let email: String
    let username: String
    let cretentAt: Timestamp
    let profileImageUrl: String

    var uid: String?

init(dic:  [String: Any]) {
    self.email = dic["email"] as? String ?? ""
    self.username = dic["username"] as? String ?? ""
    self.cretentAt = dic ["cretentAt"] as? Timestamp ?? Timestamp()
    self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
  }
}
