//
//  SimpleUser.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct SimpleUser: Codable {
    @DocumentID var id: String?
    var name: String?
    var phoneNumber: String?
    var emailAdd: String?
}
