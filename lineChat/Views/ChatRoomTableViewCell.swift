//
//  ChatRoomTableViewCell.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/16.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Msesge? {
        didSet {

           
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var mymessageTextView: UITextView!
    @IBOutlet weak var dateLaber2: UILabel!
    
    @IBOutlet weak var messgeTextViewWithConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myMessageTextViewWithConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 35
        messageTextView.layer.cornerRadius = 15
        backgroundColor = .clear
        
        mymessageTextView.layer.cornerRadius = 15
        mymessageTextView.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage() {
        guard  let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message?.uid {
            messageTextView.isHidden = true
            dateLabel.isHidden = true
            userImageView.isHidden = true
            
            mymessageTextView.isHidden = false
            dateLaber2.isHidden = false
            
            if let message = message {
                mymessageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                myMessageTextViewWithConstraint.constant = witdh
                
                dateLaber2.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
            
            
        } else {
            messageTextView.isHidden = false
            dateLabel.isHidden = false
            userImageView.isHidden = false
            
            mymessageTextView.isHidden = true
            dateLaber2.isHidden = true
            if let urlString = message?.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
                
            }
            
            if let message = message {
                messageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
                messgeTextViewWithConstraint.constant = witdh
                
                dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
            }
        }
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: date)
    }
    
}


