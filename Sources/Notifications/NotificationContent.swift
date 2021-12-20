//
//  NotificationContent.swift
//  
//
//  Created by Caio Mello on 20.12.21.
//

import Foundation

public struct NotificationContent {
    let imageFilePath: String?
    let title: String
    let subtitle: String?
    let body: String?
    let date: Date
    let identifier: String
    let userInfo: [AnyHashable: Any]

    public init(imageFilePath: String?, title: String, subtitle: String?, body: String?, date: Date, identifier: String, userInfo: [AnyHashable: Any]) {
        self.imageFilePath = imageFilePath
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.date = date
        self.identifier = identifier
        self.userInfo = userInfo
    }
}
