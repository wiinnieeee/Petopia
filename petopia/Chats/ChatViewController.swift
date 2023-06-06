//
//  ChatViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import InputBarAccessoryView

class ChatViewController: MessagesViewController, DatabaseListener{
    var listenerType = ListenerType.users
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        currentUser = user
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    var currentUser: User?
    var otherUserID: String?
    weak var databaseController: DatabaseProtocol?
    var database = Firestore.firestore()
    var animal: ListingAnimal?
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var conversation: Conversation?
    var isNewConversation = false
    var otherUser: User?
    
    var messages = [Message]()
    var selfSender = Sender(senderId: (Auth.auth().currentUser?.uid)!, displayName: "Me", photoURL: "")
    
    var messagesRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        if conversation != nil {
        let database = Firestore.firestore()
        messagesRef = database.collection("conversations").document("\((conversation?.id)!)").collection("messages")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        databaseListener = messagesRef?.order(by: "date").addSnapshotListener() { (querySnapshot, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            querySnapshot?.documentChanges.forEach() {
                change in
                
                if change.type == .added {
                let snapshot = change.document
                let id = snapshot.documentID
                    _ = snapshot["id"] as? String
                let senderId = snapshot["sender_id"]  as? String
                let senderName = snapshot["name"] as? String
                let messageText = snapshot["content"] as? String
                let date = snapshot["date"]  as? String
                    _ = snapshot["is_read"] as? String
                    _ = snapshot["type"] as? String
                
                    
                let sender = Sender(senderId: senderId!, displayName: senderName ??
                                    "" , photoURL: "")
                let message = Message(sender: sender, messageId: id, sentDate: Self.dateFormatter.date(from: date!)!, kind: .text(messageText!))
                    
                self.messages.append(message)
                self.messagesCollectionView.insertSections([self.messages.count-1])
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        databaseListener?.remove()
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

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let messageID = createMessageID() else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        
        // Send Message
        if isNewConversation {
            databaseController?.createNewConversation(pet: animal?.name!, ownName: currentUser?.name, otherName: otherUser?.name, otherUserID: otherUser?.id, firstMessage: message, completion: { [weak self] success in
                if success {
                    print ("message sent")
                    self?.isNewConversation = false
                    
                    DispatchQueue.main.async {
                        self!.messagesCollectionView.reloadDataAndKeepOffset()
                    }
                     
                } else {
                    print("failed to sent")
                }
            })
            //messagesCollectionView.reloadDataAndKeepOffset()
        }
        else {
            // append to existing conversation data
            databaseController?.sendMessage(otherUserID: otherUserID, conversation: conversation?.id, name: self.title!, message: message, completion: {
                [weak self] success in
                if success {
                    print ("message sent for conversation")
                    self?.isNewConversation = false
                } else {
                    print("failed to sent")
                }
            })
        }
        inputBar.inputTextView.text = ""
    }
    
    func createMessageID () -> String? {
        // date, otherUserID, senderID
        let dateString = Self.dateFormatter.string(from: Date())
        if otherUserID == nil {
            otherUserID = otherUser?.id
        }
        let newIdentifier = "\((otherUserID)!)_\((Auth.auth().currentUser?.uid)!)_\(dateString)"
        print("Created message ID: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}
