//
//  ConversationViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ConversationViewController: MessagesViewController, MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate, InputBarAccessoryViewDelegate {
    
    var isNewConversation = false
    let otherUserEmail: String
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
  
    
    var messages = [ChatMessage]()
    
    var currentSender: SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender is nil. Email should be cached.")
        return Sender(senderId: "12", photoURL: "", displayName: "")
    }
    
    var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(senderId: email, photoURL: "", displayName: "Julie")}
    
    
    init(with email: String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = selfSender, let messageID = createMessageID() else {
            return
        }
        
        // Send Message
        if isNewConversation {
            // create convo in database
            _ = ChatMessage(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            
        }
        else {
            // append to existing data
            
        }
    }
    
    func createMessageID() -> String? {
        // date, otherUserEmail, senderEmail
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let dateString  = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail) \(currentUserEmail) \(dateString)"
        
        return newIdentifier
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        messages.append(ChatMessage(sender: currentSender, messageId: "1", sentDate: Date(), kind: .text("Hello World message")))
        
        messages.append(ChatMessage(sender: currentSender, messageId: "1", sentDate: Date(), kind: .text("Bye world")))
        
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        loadFirstMessages()
    }
    
    func loadFirstMessages() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
