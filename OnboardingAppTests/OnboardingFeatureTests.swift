import XCTest
import ComposableArchitecture
@testable import OnboardingApp

final class OnboardingFeatureTests: XCTestCase {
    
    @MainActor
    func testPagesFlowAsExpected() async {
        // prepare
        let state = OnboardingFeature.State()
        let feature = OnboardingFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        var expectedStack = StackState<OnboardingFeature.Path.State>()
        
        // test & verify
        await store.send(.path(.push(id: 0, state: .screenToS(TermsOfServiceFeature.State(agreementApproved: false))))) {
            expectedStack[id: 0] = OnboardingFeature.Path.State.screenToS(
                TermsOfServiceFeature.State(agreementApproved: false)
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 0, action: .screenToS(.nextPage)))) {
            expectedStack[id: 1] = OnboardingFeature.Path.State.screenCredentials(
                CredentialsFeature.State(
                    email: "",
                    password: "",
                    canContinue: false
                )
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 1, action: .screenCredentials(.nextPage)))) {
            expectedStack[id: 2] = .screenPersonalInfo(
                PersonalInfoFeature.State(
                    firstName: "",
                    lastName: "",
                    telephone: "",
                    canContinue: false
                )
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 2, action: .screenPersonalInfo(.nextPage)))) {
            expectedStack[id: 3] = .screenNewPin(
                NewPinFeature.State(
                    pinValue: "",
                    canContinue: false
                )
            )
            $0.path = expectedStack
            $0.userDetails = UserDetails(firstName: "", lastName: "", telephone: "")
        }
        
        await store.send(.path(.element(id: 3, action: .screenNewPin(.nextPage)))) {
            expectedStack[id: 4] = .screenConfirmPin(
                ConfirmPinFeature.State(
                    pinToConfirm: "",
                    pinValue: "",
                    canContinue: false,
                    pinErrorLabel: nil
                )
            )
            $0.path = expectedStack
            $0.userDetails = UserDetails(firstName: "", lastName: "", telephone: "")
        }
        
        await store.send(.path(.element(id: StackElementID(4), action: .screenConfirmPin(.nextPage)))) {
            $0.path = expectedStack
            $0.userDetails = UserDetails(firstName: "", lastName: "", telephone: "")
            $0.pinCode = ""
        }
        
        await store.receive(.finished)
    }
    
    @MainActor
    func testSavesCredentialsOnNextPageEvent() async {
        // prepare
        let state = OnboardingFeature.State()
        let feature = OnboardingFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        var expectedStack = StackState<OnboardingFeature.Path.State>()
        
        // test & verify
        await store.send(.path(.push(id: 0, state: .screenCredentials(CredentialsFeature.State(email: "email", password: "password"))))) {
            expectedStack[id: 0] = .screenCredentials(
                CredentialsFeature.State(email: "email", password: "password")
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 0, action: .screenCredentials(.nextPage)))) {
            expectedStack[id: 1] = .screenPersonalInfo(
                PersonalInfoFeature.State(
                    firstName: "",
                    lastName: "",
                    telephone: "",
                    canContinue: false
                )
            )
            $0.path = expectedStack
            $0.email = "email"
            $0.password = "password"
        }
    }
    
    @MainActor
    func testSavesPersonalDetailsOnNextPageEvent() async {
        // prepare
        let state = OnboardingFeature.State()
        let feature = OnboardingFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        var expectedStack = StackState<OnboardingFeature.Path.State>()
        
        // test & verify
        await store.send(.path(.push(id: 0, state: .screenPersonalInfo(PersonalInfoFeature.State(firstName: "firstName", lastName: "lastName", telephone: "telephone"))))) {
            expectedStack[id: 0] = .screenPersonalInfo(
                PersonalInfoFeature.State(firstName: "firstName", lastName: "lastName", telephone: "telephone")
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 0, action: .screenPersonalInfo(.nextPage)))) {
            expectedStack[id: 1] = .screenNewPin(
                NewPinFeature.State(
                    pinValue: "",
                    canContinue: false
                )
            )
            $0.path = expectedStack
            $0.userDetails = UserDetails(firstName: "firstName", lastName: "lastName", telephone: "telephone")
        }
    }
    
    @MainActor
    func testCarriesOverPinCodeToConfirmationPage() async {
        // prepare
        let state = OnboardingFeature.State()
        let feature = OnboardingFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        var expectedStack = StackState<OnboardingFeature.Path.State>()
        
        // test & verify
        await store.send(.path(.push(id: 0, state: .screenNewPin(NewPinFeature.State(pinValue: "1234", canContinue: false))))) {
            expectedStack[id: 0] = .screenNewPin(
                NewPinFeature.State(pinValue: "1234", canContinue: false)
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 0, action: .screenNewPin(.nextPage)))) {
            expectedStack[id: 1] = .screenConfirmPin(
                ConfirmPinFeature.State(pinToConfirm: "1234", pinValue: "", canContinue: false, pinErrorLabel: nil)
            )
            $0.path = expectedStack
        }
    }
    
    @MainActor
    func testSavesPinCodeOnNextPageEvent() async {
        // prepare
        let state = OnboardingFeature.State()
        let feature = OnboardingFeature()
        let store = TestStore(
            initialState: state,
            reducer: feature
        )
        var expectedStack = StackState<OnboardingFeature.Path.State>()
        
        // test & verify
        await store.send(.path(.push(id: 0, state: .screenConfirmPin(ConfirmPinFeature.State(pinToConfirm: "1234", pinValue: "1234", canContinue: false, pinErrorLabel: nil))))) {
            expectedStack[id: 0] = .screenConfirmPin(
                ConfirmPinFeature.State(pinToConfirm: "1234", pinValue: "1234", canContinue: false, pinErrorLabel: nil)
            )
            $0.path = expectedStack
        }
        
        await store.send(.path(.element(id: 0, action: .screenConfirmPin(.nextPage)))) {
            expectedStack[id: 0] = .screenConfirmPin(
                ConfirmPinFeature.State(pinToConfirm: "1234", pinValue: "1234", canContinue: false, pinErrorLabel: nil)
            )
            $0.path = expectedStack
            $0.pinCode = "1234"
        }
        
        await store.receive(.finished)
    }
}
