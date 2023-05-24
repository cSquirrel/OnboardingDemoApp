import SwiftUI
import ComposableArchitecture

struct CredentialsFeature: ReducerProtocol {
    
    struct State: Codable, Equatable, Hashable  {
        var email: String = ""
        var password: String = ""
        var canContinue: Bool = false
    }
    
    enum Action: Equatable {
        case nextPage
        case previousPage
        case emailChanged(newValue: String)
        case passwordChanged(newValue: String)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(newValue):
                state.email = newValue
                state.canContinue = isValid(email: state.email, password: state.password)
                return .none
            case let .passwordChanged(newValue):
                state.password = newValue
                state.canContinue = isValid(email: state.email, password: state.password)
                return .none
            default:
                return .none
            }
        }
    }
    
    private func isValid(email: String, password: String) -> Bool {
        var result: Bool = true
        
        result = result && (email.count >= 3)
        result = result && (password.count >= 5)
        
        return result
    }
}

struct CredentialsView: View {
    let store: StoreOf<CredentialsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            OnboardingPageView() {
                Spacer()
                VStack(alignment: .leading) {
                    DecoratedTextView(placeholderText: "Email",
                                      textValue: viewStore.binding(get: \.email, send: CredentialsFeature.Action.emailChanged),
                                      errorMessage: .constant(nil),
                                      hintLabel: "Minimum 3 characters")
                    
                    DecoratedTextView(placeholderText: "Password",
                                      textValue: viewStore.binding(get: \.password, send: CredentialsFeature.Action.passwordChanged),
                                      errorMessage: .constant(nil),
                                      hintLabel: "Minimum 5 characters")
                }
                Spacer()
            } bottomContent: {
                HStack {
                    Button {
                        viewStore.send(.nextPage)
                    } label: {
                        Text("Continue")
                    }.disabled(!viewStore.canContinue)
                        .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Credentials")
        }
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(store: Store(initialState: CredentialsFeature.State(), reducer: CredentialsFeature()))
    }
}
