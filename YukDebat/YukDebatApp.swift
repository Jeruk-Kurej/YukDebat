//
//  YukDebatApp.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 13/05/26.
//

// MARK: - YukDebatApp - Entry Point

import FirebaseCore
import SwiftUI
import UserNotifications

/// Handles application lifecycle and push notification delegates.
class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Forces local notifications to display as banners even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

/// The root view orchestrating authentication state and routing.
struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.userSession != nil {
                if authVM.isLoading && authVM.currentUser == nil {
                    ZStack {
                        Color.bgCream.ignoresSafeArea()
                        ProgressView("Memuat Data Pengguna...")
                    }
                } else {
                    MainView()
                }
            } else {
                AuthView()
            }
        }
    }
}

@main
struct YukDebatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
