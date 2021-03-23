//
//  UserListViewController.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/17.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke
import FirebaseAuth



class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 10
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatbutton), for: .touchUpInside)
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        fetcUserInfoForomFierstore()
    }
    
    @objc func tappedStartChatbutton() {
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        guard let partnerUid = self.selectedUser?.uid else { return  }
        
        let menbars = [uid, partnerUid]
        
        let docData = [
            "menbers": menbars,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]
        
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRooms失敗\(err)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("Chat成功")
            
        }
    }
    
    private func fetcUserInfoForomFierstore() {
        Firestore.firestore().collection("users").getDocuments { (snapshot, err) in
            if let err = err {
                print("USER失敗\(err)")
                return
            }
            
            snapshot?.documents.forEach({ (snapshott) in
                let dic = snapshott.data()
                let user = User.init(dic: dic)
                user.uid = snapshott.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshott.documentID {
                    return
                }
               
                self.users.append(user)
                self.userListTableView.reloadData()
                
                self.users.forEach { (user) in
                    print(user.username)
                }
            })
        }
        
    }
    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        startChatButton.isEnabled = true
        self.selectedUser = user
        print("pp",user.username)
    }
    
}

class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 32.5
        
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
