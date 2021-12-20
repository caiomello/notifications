//
//  NotificationService.swift
//  
//
//  Created by Caio Mello on 10.11.21.
//

import Foundation
import UserNotifications
import UniformTypeIdentifiers

public protocol NotificationServiceDelegate {
    var notificationsEnabled: Bool { get }
    var notificationTime: Int { get }
}

public struct NotificationService {
    private let delegate: NotificationServiceDelegate
    private let debugMode: Bool

    public init(delegate: NotificationServiceDelegate, debugMode: Bool = false) {
        self.delegate = delegate
        self.debugMode = debugMode
    }
}

// MARK: - Operations

extension NotificationService {
    public func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
            completion(granted)
        }
    }

    public func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    public func scheduleNotifications(withContent content: [NotificationContent]) {
        if self.delegate.notificationsEnabled {
            content.forEach({ self.scheduleNotification(withContent: $0) })
        }
    }

    private func scheduleNotification(withContent content: NotificationContent) {
        let notification = UNMutableNotificationContent()
        notification.title = content.title
        notification.userInfo = content.userInfo

        if let subtitle = content.subtitle {
            notification.subtitle = subtitle
        }

        if let body = content.body {
            notification.body = body
        }

        if let imagePath = content.imageFilePath, let attachment = imageAttachment(withPath: imagePath) {
            notification.attachments = [attachment]
        }

        let components: DateComponents = {
            if debugMode {
                // Test components (fire 2s from now)
                return Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: Date().addingTimeInterval(2))
            } else {
                var components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: content.date)
                components.hour = delegate.notificationTime
                return components
            }
        }()

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: content.identifier, content: notification, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        })
    }

    public func cancelNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Helpers

extension NotificationService {
    private func imageAttachment(withPath path: String) -> UNNotificationAttachment? {
        let originalFileURL = URL(fileURLWithPath: path)
        let copyFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        let copyFileURL = copyFolderURL.appendingPathComponent(originalFileURL.lastPathComponent)

        do {
            try FileManager.default.createDirectory(atPath: copyFolderURL.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.copyItem(atPath: originalFileURL.path, toPath: copyFileURL.path)

            return try UNNotificationAttachment(identifier: "image",
                                                url: copyFileURL,
                                                options: [UNNotificationAttachmentOptionsTypeHintKey: UTType.jpeg])

        } catch {
            print("Error creating notification attachment: \(error)")
            return nil
        }
    }
}
