import SwiftUI
import ComposableArchitecture
import Combine

struct ConfirmPinFeature: ReducerProtocol {
    
    struct State: Codable, Equatable, Hashable {
        var pinToConfirm: String = ""
        var pinValue: String = ""
        var canContinue: Bool = false
        @BindingState var pinErrorLabel: String? = nil
    }
    
    enum Action: BindableAction, Equatable {
        case nextPage
        case previousPage
        case pinChanged(newValue: String)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .pinChanged(newValue):
                state.pinValue = newValue
                state.canContinue = false
                state.pinErrorLabel = nil
                if newValue.count == state.pinToConfirm.count {
                    if newValue == state.pinToConfirm {
                        state.canContinue = true
                    } else {
                        state.pinErrorLabel = "Pin code mismatch"
                    }
                }
                return .none
            default:
                return .none
            }
        }
    }
}

struct ConfirmPinView: View {
    let store: StoreOf<ConfirmPinFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            OnboardingPageView() {
                Spacer()
                DecoratedTextView(placeholderText: "Confirm pin code",
                                  textValue: viewStore.binding(get: \.pinValue, send: ConfirmPinFeature.Action.pinChanged),
                                  errorMessage: viewStore.binding(\.$pinErrorLabel),
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
            .navigationTitle("Confirm Pin")
        }
    }
}

struct ConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmPinView(store: Store(initialState: ConfirmPinFeature.State(pinToConfirm: "1234"), reducer: ConfirmPinFeature()))
    }
}
