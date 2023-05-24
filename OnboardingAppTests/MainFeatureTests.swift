import XCTest
import ComposableArchitecture
@testable import OnboardingApp

final class MainFeatureTests: XCTestCase {

    @MainActor
    func testUserNotAuthenticatedAtStart() async {
        // prepare
        let userDetails = UserDetails(firstName: "first", lastName: "last", telephone: "phone")
        let userCredentials = UserCredentials(email: "email", password: "password", pinCode: "1234")
        let state = MainFeature.State(userDetails: userDetails, userCredentials: userCredentials)
        let feature = MainFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        XCTAssertFalse(store.state.isAuthenticated)
    }
    
    @MainActor
    func testUserEnteredValidPin() async {
        // prepare
        let userDetails = UserDetails(firstName: "first", lastName: "last", telephone: "phone")
        let userCredentials = UserCredentials(email: "email", password: "password", pinCode: "1234")
        let state = MainFeature.State(userDetails: userDetails, userCredentials: userCredentials)
        let feature = MainFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        await store.send(.pinChanged(newValue: "1234")) {
            $0.pinValue = "1234"
            $0.isAuthenticated = true
        }
        await store.receive(.doLogIn)
    }
    
    @MainActor
    func testUserEnteredInvalidPin() async {
        // prepare
        let userDetails = UserDetails(firstName: "first", lastName: "last", telephone: "phone")
        let userCredentials = UserCredentials(email: "email", password: "password", pinCode: "1234")
        let state = MainFeature.State(userDetails: userDetails, userCredentials: userCredentials)
        let feature = MainFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        await store.send(.pinChanged(newValue: "6789")) {
            $0.pinValue = "6789"
            $0.isAuthenticated = false
            $0.pinErrorLabel = "Invalid pin code"
        }
    }
}
