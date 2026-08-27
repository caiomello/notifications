//
//  NotificationContent.swift
//  
//
//  Created by Caio Mello on 20.12.21.
//

import Foundation

public struct NotificationContent: Sendable {
    public let identifier: String
    public let title: String
    public let date: Date
    public let subtitle: String?
    public let body: String?
    public let imageFilePath: String?
    public let userInfo: [String: any Sendable]

    public init(identifier: String, title: String, date: Date, subtitle: String?, body: String?, imageFilePath: String?, userInfo: [String: any Sendable]) {
        self.identifier = identifier
        self.title = title
        self.date = date
        self.subtitle = subtitle
        self.body = body
        self.imageFilePath = imageFilePath
        self.userInfo = userInfo
    }
}
