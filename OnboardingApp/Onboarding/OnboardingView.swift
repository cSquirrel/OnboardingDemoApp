import SwiftUI
import ComposableArchitecture

struct OnboardingFeature: ReducerProtocol {
    
    enum Tab {
        case welcome, tos, credentials, personalInfo, newPin, confirmPin
        static let allTabs = [Self.welcome, Self.tos, Self.credentials, Self.personalInfo, Self.newPin, Self.confirmPin]
    }
    
    struct State: Equatable {
        var path = StackState<Path.State>()
        var email: String?
        var password: String?
        var pinCode: String?
        var userDetails: UserDetails?
    }
    
    enum Action: Equatable {
        case finished
        case path(StackAction<Path.State, Path.Action>)
        case start
    }
    
    struct Path: Reducer {
        enum State: Codable, Equatable, Hashable {
            case screenToS(TermsOfServiceFeature.State = .init())
            case screenCredentials(CredentialsFeature.State = .init())
            case screenPersonalInfo(PersonalInfoFeature.State = .init())
            case screenNewPin(NewPinFeature.State = .init())
            case screenConfirmPin(ConfirmPinFeature.State = .init(pinToConfirm: ""))
        }
        
        enum Action: Equatable {
            case screenToS(TermsOfServiceFeature.Action)
            case screenCredentials(CredentialsFeature.Action)
            case screenPersonalInfo(PersonalInfoFeature.Action)
            case screenNewPin(NewPinFeature.Action)
            case screenConfirmPin(ConfirmPinFeature.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: /State.screenToS, action: /Action.screenToS) {
                TermsOfServiceFeature()
            }
            Scope(state: /State.screenCredentials, action: /Action.screenCredentials) {
                CredentialsFeature()
            }
            Scope(state: /State.screenPersonalInfo, action: /Action.screenPersonalInfo) {
                PersonalInfoFeature()
            }
            Scope(state: /State.screenNewPin, action: /Action.screenNewPin) {
                NewPinFeature()
            }
            Scope(state: /State.screenConfirmPin, action: /Action.screenConfirmPin) {
                ConfirmPinFeature()
            }
            
        }
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                return .none
            case let .path(action):
                switch action {
                case .element(id: _, action: .screenToS(.nextPage)):
                    state.path.append(.screenCredentials())
                    return .none
                case let .element(id: id, action: .screenCredentials(.nextPage)):
                    guard case let .screenCredentials(credentialsState) = state.path[id: id]
                    else { return .none }
                    if !credentialsState.email.isEmpty {
                        state.email = credentialsState.email
                    }
                    if !credentialsState.password.isEmpty {
                        state.password = credentialsState.password
                    }
                    
                    state.path.append(.screenPersonalInfo())
                    return .none
                    
                case let .element(id: id, action: .screenPersonalInfo(.nextPage)):
                    guard case let .screenPersonalInfo(personalInfoState) = state.path[id: id]
                    else { return .none }
                    
                    let firstName = personalInfoState.firstName
                    let lastName = personalInfoState.lastName
                    let telephone = personalInfoState.telephone
                    state.userDetails = UserDetails(firstName: firstName, lastName: lastName, telephone: telephone)
                    
                    state.path.append(.screenNewPin())
                    return .none
                    
                case let .element(id: id, action: .screenNewPin(.nextPage)):
                    guard case let .screenNewPin(pincodeState) = state.path[id: id]
                    else { return .none }
                    
                    let pinToConfirm = pincodeState.pinValue
                    state.path.append(.screenConfirmPin(ConfirmPinFeature.State(pinToConfirm: pinToConfirm)))
                    return .none
                    
                case let .element(id: id, action: .screenConfirmPin(.nextPage)):
                    guard case let .screenConfirmPin(pincodeState) = state.path[id: id]
                    else { return .none }
                    
                    state.pinCode = pincodeState.pinValue
                    return Effect.send(.finished)
                    
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}


struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    
    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: OnboardingFeature.Action.path)
        ) {
            OnboardingPageView() {
                VStack {
                    Text("Welcome To The App")
                        .font(.largeTitle)
                    Spacer()
                    Text("We would like to take through the first steps to get you ready to use the app. We will ask you about your basic personal information and credentials. In no time you will be ready to use the app.")
                        .font(.body)
                    Spacer()
                }
            } bottomContent: {
                HStack {
                    NavigationLink(
                        "Start Onboarding",
                        state: OnboardingFeature.Path.State.screenToS()
                    )
                }
            }
        } destination: {
            switch $0 {
            case .screenToS:
                CaseLet(
                    state: /OnboardingFeature.Path.State.screenToS,
                    action: OnboardingFeature.Path.Action.screenToS,
                    then: TermsOfServiceView.init(store:)
                )
            case .screenCredentials:
                CaseLet(
                    state: /OnboardingFeature.Path.State.screenCredentials,
                    action: OnboardingFeature.Path.Action.screenCredentials,
                    then: CredentialsView.init(store:)
                )
            case .screenPersonalInfo:
                CaseLet(
                    state: /OnboardingFeature.Path.State.screenPersonalInfo,
                    action: OnboardingFeature.Path.Action.screenPersonalInfo,
                    then: PersonalInfoView.init(store:)
                )
            case .screenNewPin:
                CaseLet(
                    state: /OnboardingFeature.Path.State.screenNewPin,
                    action: OnboardingFeature.Path.Action.screenNewPin,
                    then: NewPinView.init(store:)
                )
            case .screenConfirmPin:
                CaseLet(
                    state: /OnboardingFeature.Path.State.screenConfirmPin,
                    action: OnboardingFeature.Path.Action.screenConfirmPin,
                    then: ConfirmPinView.init(store:)
                )
            }
        }
        .onAppear{
            ViewStore(self.store.stateless).send(.start)
        }
        .interactiveDismissDisabled()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: Store(initialState: OnboardingFeature.State(),
                                    reducer: OnboardingFeature()))
    }
}
