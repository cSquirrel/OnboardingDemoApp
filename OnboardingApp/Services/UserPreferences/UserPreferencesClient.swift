import Foundation
import ComposableArchitecture

extension UserPreferencesClient: DependencyKey {
    
    private enum Const {
        static let userDetailsKey = "user.details"
        static let userCredentialsKey = "user.credentials"
    }
    
    public static let liveValue: Self = {
        let defaults = { UserDefaults.standard }
        return Self(
            // -
            userDetails: {
                guard let data = defaults().data(forKey: Const.userDetailsKey) else {
                    return nil
                }
                let userDetails = try JSONDecoder().decode(UserDetails.self, from: data)
                return userDetails
            },
            setUserDetails: {
                let data = try JSONEncoder().encode($0)
                defaults().set(data, forKey: Const.userDetailsKey)
            },
            eraseUserDetails: {
                defaults().removeObject(forKey: Const.userDetailsKey)
            },
            // -
            userCredentials: {
                guard let data = defaults().data(forKey: Const.userCredentialsKey) else {
                    return nil
                }
                let userDetails = try JSONDecoder().decode(UserCredentials.self, from: data)
                return userDetails
            },
            setUserCredentials: {
                let data = try JSONEncoder().encode($0)
                defaults().set(data, forKey: Const.userCredentialsKey)
            },
            eraseUserCredentials: {
                defaults().removeObject(forKey: Const.userCredentialsKey)
            }
        )
    }()
}

extension UserPreferencesClient: TestDependencyKey {
    static let testValue = Self(
        userDetails: XCTUnimplemented("\(Self.self).userDetails", placeholder: nil),
        setUserDetails: XCTUnimplemented("\(Self.self).setUserDetails"),
        eraseUserDetails: XCTUnimplemented("\(Self.self).eraseUserDetails"),
        userCredentials: XCTUnimplemented("\(Self.self).userDetails", placeholder: nil),
        setUserCredentials: XCTUnimplemented("\(Self.self).setUserDetails"),
        eraseUserCredentials: XCTUnimplemented("\(Self.self).eraseUserDetails")
    )
}

extension DependencyValues {
    var userPreferences: UserPreferencesClient {
        get { self[UserPreferencesClient.self] }
        set { self[UserPreferencesClient.self] = newValue }
    }
}

struct UserPreferencesClient {
    // -
    var userDetails: @Sendable() throws -> UserDetails?
    var setUserDetails: @Sendable(UserDetails) throws -> Void
    var eraseUserDetails: @Sendable() -> Void
    // -
    var userCredentials: @Sendable() throws -> UserCredentials?
    var setUserCredentials: @Sendable(UserCredentials) throws -> Void
    var eraseUserCredentials: @Sendable() -> Void
}
