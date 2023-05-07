//
//  ConversationViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import UIKit
import MessageKit

class ConversationViewController: MessagesViewController, MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    
    
    
    var messages = [ChatMessage]()
    
    var currentSender: SenderType {
        return selfSender
    }
    
    let selfSender = Sender(senderId: "1", photoURL: "", displayName: "Joe Smith")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        messages.append(ChatMessage(sender: currentSender, messageId: "1", sentDate: Date(), kind: .text("Hello World message")))
        
        messages.append(ChatMessage(sender: currentSender, messageId: "1", sentDate: Date(), kind: .text("Bye world")))
        
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadFirstMessages()
    }
    
    func loadFirstMessages() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
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
