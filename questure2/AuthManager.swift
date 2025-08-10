import Foundation
import AuthenticationServices
import UIKit

final class AuthManager: NSObject, ObservableObject {
    @Published private(set) var isSignedIn: Bool = false
    @Published private(set) var displayName: String = ""
    @Published private(set) var userIdentifier: String?

    private let userIdDefaultsKey = "appleUserIdentifier"

    override init() {
        super.init()
        restorePreviousSignIn()
    }

    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func signOut() {
        isSignedIn = false
        displayName = ""
        userIdentifier = nil
        UserDefaults.standard.removeObject(forKey: userIdDefaultsKey)
    }

    private func restorePreviousSignIn() {
        if let storedId = UserDefaults.standard.string(forKey: userIdDefaultsKey) {
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: storedId) { [weak self] state, _ in
                DispatchQueue.main.async {
                    self?.userIdentifier = storedId
                    self?.isSignedIn = (state == .authorized)
                }
            }
        }
    }

    // Allow SwiftUI's SignInWithAppleButton to hand us the auth result directly
    func handle(authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userIdentifier = credential.user
            isSignedIn = true
            if let name = credential.fullName {
                let formatter = PersonNameComponentsFormatter()
                displayName = formatter.string(from: name)
            }
            UserDefaults.standard.set(credential.user, forKey: userIdDefaultsKey)
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userIdentifier = credential.user
            isSignedIn = true
            if let name = credential.fullName {
                let formatter = PersonNameComponentsFormatter()
                displayName = formatter.string(from: name)
            }
            // Persist user id for future credential state checks
            UserDefaults.standard.set(credential.user, forKey: userIdDefaultsKey)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isSignedIn = false
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Best-effort to get the key window
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
}


