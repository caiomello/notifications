//
//  NotificationContent.swift
//  
//
//  Created by Caio Mello on 20.12.21.
//

import Foundation

public struct NotificationContent {
    let identifier: String
    let title: String
    let date: Date
    let subtitle: String?
    let body: String?
    let imageFilePath: String?
    let userInfo: [AnyHashable: Any]

    public init(identifier: String, title: String, date: Date, subtitle: String?, body: String?, imageFilePath: String?, userInfo: [AnyHashable : Any]) {
        self.identifier = identifier
        self.title = title
        self.date = date
        self.subtitle = subtitle
        self.body = body
        self.imageFilePath = imageFilePath
        self.userInfo = userInfo
    }
}
