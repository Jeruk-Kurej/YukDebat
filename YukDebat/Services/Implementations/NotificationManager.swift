//
//  NotificationManager.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 02/06/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Meminta izin notifikasi kepada user saat aplikasi pertama kali dibuka
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if granted {
                print("✅ Izin notifikasi diberikan.")
            } else if let error = error {
                print(
                    "❌ Gagal meminta izin notifikasi: \(error.localizedDescription)"
                )
            }
        }
    }

    /// Memicu notifikasi lokal secara instan
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Pemicu waktu berjalan setelah 1 detik
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "❌ Gagal mengirim notifikasi lokal: \(error.localizedDescription)"
                )
            }
        }
    }
}
