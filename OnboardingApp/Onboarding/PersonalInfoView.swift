import SwiftUI
import ComposableArchitecture

struct PersonalInfoFeature: ReducerProtocol {
    
    struct State: Codable, Equatable, Hashable {
        var firstName: String = ""
        var lastName: String = ""
        var telephone: String = ""
        var canContinue: Bool = false
    }
    
    enum Action: Equatable {
        case nextPage
        case previousPage
        case firstNameChanged(newValue: String)
        case lastNameChanged(newValue: String)
        case telephoneChanged(newValue: String)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .firstNameChanged(newValue):
                state.firstName = newValue
                state.canContinue = isValid(firstName: state.firstName, lastName: state.lastName, telephone: state.telephone)
                return .none
            case let .lastNameChanged(newValue):
                state.lastName = newValue
                state.canContinue = isValid(firstName: state.firstName, lastName: state.lastName, telephone: state.telephone)
                return .none
            case let .telephoneChanged(newValue):
                state.telephone = newValue
                state.canContinue = isValid(firstName: state.firstName, lastName: state.lastName, telephone: state.telephone)
                return .none
            default:
                return .none
            }
        }
    }
    
    private func isValid(firstName: String, lastName: String, telephone: String) -> Bool {
        var result: Bool = true
        
        result = result && !firstName.isEmpty
        result = result && !lastName.isEmpty
        result = result && !telephone.isEmpty
        
        return result
    }
}

struct PersonalInfoView: View {
    let store: StoreOf<PersonalInfoFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            OnboardingPageView() {
                Spacer()
                VStack(alignment: .leading) {
                    DecoratedTextView(placeholderText: "First name",
                                      textValue: viewStore.binding(get: \.firstName, send: PersonalInfoFeature.Action.firstNameChanged),
                                      errorMessage: .constant(nil))
                    DecoratedTextView(placeholderText: "Last name",
                                      textValue: viewStore.binding(get: \.lastName, send: PersonalInfoFeature.Action.lastNameChanged),
                                      errorMessage: .constant(nil))
                    DecoratedTextView(placeholderText: "Telephone",
                                      textValue: viewStore.binding(get: \.telephone, send: PersonalInfoFeature.Action.telephoneChanged),
                                      errorMessage: .constant(nil))
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
            .navigationTitle("Personal Info")
        }
    }
}

struct PersonalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInfoView(store: Store(initialState: PersonalInfoFeature.State(), reducer: PersonalInfoFeature()))
    }
}
