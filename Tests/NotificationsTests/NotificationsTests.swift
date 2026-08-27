import Foundation
import Testing

@testable import Notifications

private struct TestDelegate: NotificationServiceDelegate {
    var notificationsEnabled: Bool
    var notificationTime: Int
}

@Suite("NotificationContent")
struct NotificationContentTests {
    @Test("Stores the values it was initialized with")
    func storesInitializedValues() {
        let date = Date(timeIntervalSince1970: 0)

        let content = NotificationContent(
            identifier: "id",
            title: "Title",
            date: date,
            subtitle: "Subtitle",
            body: "Body",
            imageFilePath: "/tmp/image.jpg",
            userInfo: ["key": "value"]
        )

        #expect(content.identifier == "id")
        #expect(content.title == "Title")
        #expect(content.date == date)
        #expect(content.subtitle == "Subtitle")
        #expect(content.body == "Body")
        #expect(content.imageFilePath == "/tmp/image.jpg")
        #expect(content.userInfo["key"] as? String == "value")
    }

    @Test("Optional fields accept nil")
    func optionalFieldsAcceptNil() {
        let content = NotificationContent(
            identifier: "id",
            title: "Title",
            date: Date(),
            subtitle: nil,
            body: nil,
            imageFilePath: nil,
            userInfo: [:]
        )

        #expect(content.subtitle == nil)
        #expect(content.body == nil)
        #expect(content.imageFilePath == nil)
        #expect(content.userInfo.isEmpty)
    }
}

@Suite("NotificationService")
struct NotificationServiceTests {
    @Test("Scheduling is a no-op when the delegate has notifications disabled")
    func schedulingIsSkippedWhenDisabled() async throws {
        let service = NotificationService(delegate: TestDelegate(notificationsEnabled: false, notificationTime: 9))

        let content = (0..<3).map { index in
            NotificationContent(
                identifier: "id-\(index)",
                title: "Title \(index)",
                date: Date(),
                subtitle: nil,
                body: nil,
                imageFilePath: nil,
                userInfo: [:]
            )
        }

        // Nothing reaches UNUserNotificationCenter, so this must return without throwing.
        try await service.scheduleNotifications(withContent: content)
    }

    @Test("Scheduling an empty batch does nothing")
    func schedulingEmptyBatchDoesNothing() async throws {
        let service = NotificationService(delegate: TestDelegate(notificationsEnabled: true, notificationTime: 9))

        try await service.scheduleNotifications(withContent: [])
    }
}
