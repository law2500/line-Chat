//
//  ChatRoomViewController.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ChatRoomViewController: UIViewController {
    
    private let cellId = "cellId"
    private var messages = [Msesge]()
    
    var chatroom: ChatRoom?
    var user : User?
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        chatRoomTableView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.6748230903, blue: 0.9764705896, alpha: 1)
        fetchMessages()
        chatRoomTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    override var inputAccessoryView: UIView? {
        get{
            return chatInputAccessoryView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messags")
            .addSnapshotListener { (snapshos, err) in
                if let err = err {
                    print("失敗しました\(err)")
                    return
                }
                
                snapshos?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        let dic = documentChange.document.data()
                        let message = Msesge(dic: dic)
                        message.partnerUser = self.chatroom?.partnerUser
                        
                        self.messages.append(message)
                        self.messages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                        }
                        self.chatRoomTableView.reloadData()
                        
                        
                        
                        print(dic)
                    case .modified, .removed:
                        print("ok")
                        
                    }
                })
                
            }
    }
    
}

extension ChatRoomViewController: ChatInputAccessoryViewderegate {
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId)
            .collection("messags").document(messageId).setData(docData) { (err) in
                if let err = err {
                    print("message\(err)")
                    return
                }
                
                let latestMessageData = [
                    "latestMessageId": messageId
                ]
                
                Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                    if let err = err {
                        print("失敗です最新\(err)")
                    }
                    print("M成功")
                }
            }
         }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}


extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatRoomTableViewCell
        cell.message = messages[indexPath.row]
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        return cell
    }
    
    
 }

