import SwiftUI
import ComposableArchitecture

struct MainFeature: ReducerProtocol {
    
    private enum Const {
        static let defaultHint = "Exactly 4 digits"
        static let invalidPin = "Invalid pin code"
    }
    
    struct State: Equatable {
        let userDetails: UserDetails
        let userCredentials: UserCredentials
        var pinValue = ""
        let pinHintLabel = Const.defaultHint
        @BindingState var pinErrorLabel: String? = nil
        var isAuthenticated = false
    }
    
    enum Action: BindableAction, Equatable {
        case signOut
        case pinChanged(newValue: String)
        case doLogIn
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .pinChanged(newValue):
                state.pinValue = newValue
                state.pinErrorLabel = nil
                if newValue.count == state.userCredentials.pinCode.count {
                    if newValue == state.userCredentials.pinCode {
                        state.isAuthenticated = true
                        return Effect.send(.doLogIn)
                    } else {
                        state.pinErrorLabel = Const.invalidPin
                    }
                }
                return .none
            default:
                return .none
            }
        }
    }
}

struct MainView: View {
    let store: StoreOf<MainFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            VStack {
                if viewStore.isAuthenticated {
                    VStack {
                        Text("Hello \(viewStore.userDetails.firstName) \(viewStore.userDetails.lastName) 👋🏻")
                        Text("Your details: \n - telephone: \(viewStore.userDetails.telephone) \n - email: \(viewStore.userCredentials.email)")
                        Button {
                            viewStore.send(.signOut)
                        } label: {
                            Text("Sign Out")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack {
                        Text("Please enter your pin to access the app")
                        DecoratedTextView(placeholderText: "Pin code",
                                          textValue: viewStore.binding(get: \.pinValue, send: MainFeature.Action.pinChanged),
                                          errorMessage: viewStore.binding(\.$pinErrorLabel),
                                          hintLabel: viewStore.pinHintLabel)
                        .padding([.leading, .trailing], 48)
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView(store: Store(initialState: MainFeature.State(
            userDetails: UserDetails(firstName: "John", lastName: "Appleseed", telephone: "09784538767"),
            userCredentials: UserCredentials(email: "email", password: "password", pinCode: "1234"),
            isAuthenticated: false
        ), reducer: MainFeature()))
        .previewDisplayName("Not Authenticated")
        MainView(store: Store(initialState: MainFeature.State(
            userDetails: UserDetails(firstName: "John", lastName: "Appleseed", telephone: "09784538767"),
            userCredentials: UserCredentials(email: "email", password: "password", pinCode: "1234"),
            isAuthenticated: true
        ), reducer: MainFeature()))
        .previewDisplayName("Authenticated")
    }
}

