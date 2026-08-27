//
//  NotificationService.swift
//  
//
//  Created by Caio Mello on 10.11.21.
//

import Foundation
import OSLog
import UniformTypeIdentifiers
import UserNotifications

public protocol NotificationServiceDelegate: Sendable {
    var notificationsEnabled: Bool { get }
    var notificationTime: Int { get }
}

public struct NotificationService: Sendable {
    private let delegate: any NotificationServiceDelegate
    private let debugMode: Bool

    private let logger = Logger(subsystem: "Notifications", category: "NotificationService")

    public init(delegate: any NotificationServiceDelegate, debugMode: Bool = false) {
        self.delegate = delegate
        self.debugMode = debugMode
    }
}

// MARK: - Operations

extension NotificationService {
    public func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge])
    }

    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    public func scheduleNotifications(withContent content: [NotificationContent]) async throws {
        guard delegate.notificationsEnabled else { return }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for item in content {
                group.addTask { try await scheduleNotification(withContent: item) }
            }

            try await group.waitForAll()
        }
    }

    @concurrent
    private func scheduleNotification(withContent content: NotificationContent) async throws {
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

        try await UNUserNotificationCenter.current().add(request)
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
        let copyFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        let copyFileURL = copyFolderURL.appendingPathComponent(originalFileURL.lastPathComponent).appendingPathExtension(for: .jpeg)

        do {
            try FileManager.default.createDirectory(at: copyFolderURL, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: originalFileURL, to: copyFileURL)

            return try UNNotificationAttachment(
                identifier: "image",
                url: copyFileURL,
                options: [UNNotificationAttachmentOptionsTypeHintKey: UTType.jpeg.identifier]
            )
        } catch {
            logger.error("Error creating notification attachment: \(error.localizedDescription, privacy: .public)")
            try? FileManager.default.removeItem(at: copyFolderURL)
            return nil
        }
    }
}
