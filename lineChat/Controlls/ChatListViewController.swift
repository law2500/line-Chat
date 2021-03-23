//
//  ChatListViewController.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke

class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var chatRoomListener: ListenerRegistration?
    private var user: User? {
        didSet{
            navigationItem.title = user?.username
        }
    }
    @IBOutlet weak var chatListTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoginUser()
        fetchChatroomsInfoFromFierstire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLoginUserInfo()
        
    }
    
    
    func fetchChatroomsInfoFromFierstire() {
        chatRoomListener?.remove()
        chatrooms.removeAll()
        chatListTableView.reloadData()
        
        chatRoomListener = Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshos, err) in
                if let err = err {
                    print("chatRooms習得失敗\(err)")
                    return
                }
                
                snapshos?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("no")
                    }
                })
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isConatin = chatroom.menbers.contains(uid)
        
        if !isConatin { return }
        chatroom.menbers.forEach { (menberUid) in
            if menberUid != uid {
                Firestore.firestore().collection("users").document(menberUid).getDocument { (snapshot, err) in
                    if let err = err {
                        print("失敗しました\(err)")
                        return
                    }
                    
                    guard  let dic = snapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    
                    guard let chatroomId = chatroom.documentId  else { return }
                    let latestMessageId = chatroom.latestMessageId
                    
                    if latestMessageId == "" {
                        chatroom.partnerUser = user
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    
                    Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messags").document(latestMessageId).getDocument { (snapshott, err) in
                        if let err = err {
                            print("表示失敗\(err)")
                            return
                        }
                        
                        guard  let dic = snapshott?.data() else { return }
                        let message = Msesge(dic: dic)
                        chatroom.letestMssage = message
                        
                        
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let rigntBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightButton))
        let logOutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappndLogOutButton))
        navigationItem.rightBarButtonItem = rigntBarButton
        navigationItem.leftBarButtonItem = logOutBarButton
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @objc private func tappndLogOutButton() {
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました。\(error)")
        }
        
    }
    
    private func confirmLoginUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func pushLoginViewController() {
        let storyboar = UIStoryboard(name: "SignUp", bundle: nil)
        let signUPViewController = storyboar.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUPViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func tappedNavRightButton() {
        let storybord = UIStoryboard(name: "UserList", bundle: nil)
        let userListViewController = storybord.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("log失敗\(err)")
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            self.user = user
        }
    }
    
}




extension ChatListViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}



class ChatListTableViewCell: UITableViewCell {
    
    
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                deteLabel.text = dateFormatterForDateLabel(date: chatroom.letestMssage?.createdAt.dateValue() ?? Date())
                latestMessageLabel.text = chatroom.letestMssage?.message
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var deteLabel: UILabel!
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: date)
    }
    
    
    
    
    
}
