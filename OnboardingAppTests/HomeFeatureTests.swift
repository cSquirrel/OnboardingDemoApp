import XCTest
import ComposableArchitecture
@testable import OnboardingApp

final class HomeFeatureTests: XCTestCase {
    
    @MainActor
    func testNoUserDataShowsOnboardingFeature() async {
        // prepare
        var userPrefs = UserPreferencesClient.testValue
        userPrefs.userDetails = { return nil }
        userPrefs.userCredentials = { return nil }
        let state = HomeFeature.State()
        let feature = withDependencies {
            $0.userPreferences = userPrefs
        } operation: {
            HomeFeature()
        }
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        await store.send(.start)
        await store.receive(.showOnboarding) {
            $0.onboarding = OnboardingFeature.State()
        }
    }
    
    @MainActor
    func testExistingUserDataShowsMainFeature() async {
        // prepare
        let userDetails = UserDetails(firstName: "first", lastName: "last", telephone: "phone")
        let userCredentials = UserCredentials(email: "email", password: "password", pinCode: "1234")
        var userPrefs = UserPreferencesClient.testValue
        userPrefs.userDetails = { return userDetails }
        userPrefs.userCredentials = { return userCredentials }
        let state = HomeFeature.State()
        let feature = withDependencies {
            $0.userPreferences = userPrefs
        } operation: {
            HomeFeature()
        }
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        await store.send(.start) {
            $0.main = MainFeature.State(userDetails: userDetails, userCredentials: userCredentials)
        }
    }
    
    @MainActor
    func testFinishedEventSavesDataAndShowsMainScreen() async {
        // prepare
        let shouldSetUserDetails = expectation(description: "")
        let shouldSetUserCredentials = expectation(description: "")
        let userDetails = UserDetails(firstName: "firstName", lastName: "lastName", telephone: "telephone")
        let userCredentials = UserCredentials(email: "email", password: "password", pinCode: "1234")
        var userPrefs = UserPreferencesClient.testValue
        userPrefs.userDetails = { return userDetails }
        userPrefs.userCredentials = { return userCredentials }
        userPrefs.setUserDetails = {
            XCTAssertEqual($0, userDetails)
            shouldSetUserDetails.fulfill()
        }
        userPrefs.setUserCredentials = {
            XCTAssertEqual($0, userCredentials)
            shouldSetUserCredentials.fulfill()
        }
        let onboardingState = OnboardingFeature.State(
            path: StackState<OnboardingFeature.Path.State>(),
            email: "email",
            password: "password",
            pinCode: "1234",
            userDetails: UserDetails(firstName: "firstName",
                                     lastName: "lastName",
                                     telephone: "telephone")
        )
        let state = HomeFeature.State(onboarding: onboardingState)
        let feature = withDependencies {
            $0.userPreferences = userPrefs
        } operation: {
            HomeFeature()
        }
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        
        // test & verify
        await store.send(.onboarding(.finished))
        await store.receive(.start) {
            
            $0.onboarding = nil
            $0.main = MainFeature.State(
                userDetails: UserDetails(
                    firstName: "firstName",
                    lastName: "lastName",
                    telephone: "telephone"
                ),
                userCredentials: UserCredentials(
                    email: "email",
                    password: "password",
                    pinCode: "1234"
                ),
                pinValue: "",
                pinErrorLabel: nil,
                isAuthenticated: false
            )
        }
        
        await fulfillment(of: [shouldSetUserDetails, shouldSetUserCredentials])
    }
    
}
