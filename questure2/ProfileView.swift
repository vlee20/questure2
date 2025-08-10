import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var healthManager: HealthKitManager

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill").font(.system(size: 48))
                        VStack(alignment: .leading) {
                            Text(authManager.isSignedIn ? (authManager.displayName.isEmpty ? "User" : authManager.displayName) : "Guest")
                                .font(.title3)
                                .bold()
                            Text(authManager.isSignedIn ? "Signed in" : "Not signed in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Integrations") {
                    HStack {
                        Text("Apple Health")
                        Spacer()
                        Image(systemName: healthManager.isAuthorized ? "checkmark.seal.fill" : "xmark.seal")
                            .foregroundStyle(healthManager.isAuthorized ? .green : .red)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { healthManager.requestAuthorizationIfNeeded() }
                }

                Section {
                    if authManager.isSignedIn {
                        Button("Sign out") { authManager.signOut() }
                            .buttonStyle(.bordered)
                    } else {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                authManager.handle(authorization: authorization)
                                // Trigger Health permission prompt after successful sign-in
                                healthManager.requestAuthorizationIfNeeded()
                            case .failure:
                                break
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 44)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
            .environmentObject(HealthKitManager())
            .environmentObject(WalletManager())
            .environmentObject(MarketplaceManager())
    }
}


