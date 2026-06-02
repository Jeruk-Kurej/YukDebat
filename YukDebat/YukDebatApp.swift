//
//  YukDebatApp.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 13/05/26.
//

import FirebaseCore
import SwiftUI
import UserNotifications  

class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // 1. Set delegate ke self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // 2. Fungsi ini memaksa banner muncul KAPANPUN (bahkan saat app terbuka)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Tampilkan banner, suara, dan badge
        completionHandler([.banner, .sound, .badge])
    }
}

// 2. Layar Pemilah Sesi (Switcher)
struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.userSession != nil {
                // Jika sedang login dan data role masih loading, tampilkan indikator
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

// 3. Entry Point Aplikasi
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
