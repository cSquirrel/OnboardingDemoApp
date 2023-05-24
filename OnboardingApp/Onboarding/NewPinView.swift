import SwiftUI
import ComposableArchitecture

struct NewPinFeature: ReducerProtocol {
    
    struct State: Codable, Equatable, Hashable {
        var pinValue: String = ""
        var canContinue: Bool = false
    }
    
    enum Action: Equatable {
        case nextPage
        case previousPage
        case pinChanged(newValue: String)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .pinChanged(newValue):
                guard newValue.count <= 4 else { return .none }
                state.pinValue = newValue
                state.canContinue = isValid(pin: state.pinValue)
                return .none
            default:
                return .none
            }
        }
    }
    
    private func isValid(pin: String) -> Bool {
        var result: Bool = true
        
        result = result && (pin.count == 4)
        
        return result
    }
}

struct NewPinView: View {
    let store: StoreOf<NewPinFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            OnboardingPageView() {
                Spacer()
                DecoratedTextView(placeholderText: "New pin code",
                                  textValue: viewStore.binding(get: \.pinValue, send: NewPinFeature.Action.pinChanged),
                                  errorMessage: .constant(nil),
                                  hintLabel: "Exactly 4 digits")
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
            .navigationTitle("New Pin")
        }
    }
}

struct NewPinView_Previews: PreviewProvider {
    static var previews: some View {
        NewPinView(store: Store(initialState: NewPinFeature.State(), reducer: NewPinFeature()))
    }
}
