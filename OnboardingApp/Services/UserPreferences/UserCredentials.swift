import Foundation

struct UserCredentials: Codable, Equatable {
    let email: String
    let password: String
    let pinCode: String
}
