//
//  AuthViewModel.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages user authentication state, registration, and user data fetching from Firestore.
@MainActor
class AuthViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var userSession: FirebaseAuth.User?
    @Published private(set) var currentUser: UserModel?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Properties

    private let db = Firestore.firestore()
    private var userListener: ListenerRegistration?

    // MARK: - Initialization

    init() {
        self.userSession = Auth.auth().currentUser
        fetchUser()
    }

    deinit {
        userListener?.remove()
    }

    // MARK: - Methods

    /// Authenticates a user with email and password.
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
                return
            }

            self?.userSession = result?.user
            self?.fetchUser()
            self?.isLoading = false
        }
    }

    /// Creates a new user account and initializes the user profile in Firestore.
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }

            guard let uid = result?.user.uid else { return }

            let userData: [String: Any] = [
                "id": uid,
                "name": fullName,
                "email": email,
                "role": UserRole.debater.rawValue,
                "isActive": true,
                "createdAt": Timestamp(date: Date()),
            ]

            self.db.collection("users").document(uid).setData(userData) {
                error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.userSession = result?.user
                self.fetchUser()
            }
        }
    }

    /// Signs out the current user and clears local session data.
    func logout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.userListener?.remove()
        } catch {
            self.errorMessage =
                "Failed to log out: \(error.localizedDescription)"
        }
    }

    /// Fetches user profile data from Firestore.
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Remove existing listener if any
        userListener?.remove()

        userListener = db.collection("users").document(uid).addSnapshotListener
        { [weak self] snapshot, _ in
            guard let self = self else { return }

            guard let data = snapshot?.data() else {
                self.errorMessage =
                    "Sesi tidak valid atau data terhapus. Silakan Register ulang."
                self.logout()
                return
            }

            let roleStr = (data["role"] as? String ?? "DEBATER").uppercased()

            self.currentUser = UserModel(
                id: uid,
                name: data["name"] as? String ?? "YukDebat User",
                email: data["email"] as? String ?? "",
                role: UserRole(rawValue: roleStr) ?? .debater,
                isActive: data["isActive"] as? Bool ?? true,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                    ?? Date()
            )

            if self.currentUser?.isActive == false {
                self.errorMessage =
                    "Akun Anda telah ditangguhkan (Suspend) oleh Administrator."
                self.logout()
            }
        }
    }

    /// Updates the display name of the user in Firestore.
    func updateName(newName: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let err = NSError(
                domain: "AuthError",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated."]
            )
            completion(err)
            return
        }

        db.collection("users").document(uid).updateData(["name": newName]) {
            error in
            completion(error)
        }
    }
}
