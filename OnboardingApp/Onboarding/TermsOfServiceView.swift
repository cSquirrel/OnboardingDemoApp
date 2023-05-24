import SwiftUI
import ComposableArchitecture

struct TermsOfServiceFeature: ReducerProtocol {
    
    struct State: Codable, Equatable, Hashable  {
        var agreementApproved: Bool = false
    }
    
    enum Action: Equatable {
        case nextPage
        case previousPage
        case agreementChanged(isOn: Bool)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .agreementChanged(isOn):
              state.agreementApproved = isOn
              return .none
            default:
                return .none
            }
        }
    }
}

struct TermsOfServiceView: View {
    let store: StoreOf<TermsOfServiceFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            OnboardingPageView() {
                ScrollView {
                    Text(tocContent)
                }
            } bottomContent: {
                Toggle(isOn: viewStore.binding(get: \.agreementApproved, send: TermsOfServiceFeature.Action.agreementChanged)) {
                    Text("I have read the terms and conditions")
                }.padding()
                HStack {
                    Spacer()
                    Button {
                        viewStore.send(.nextPage)
                    } label: {
                        Text("Continue")
                    }
                    .disabled(!viewStore.agreementApproved)
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Terms Of Service")
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView(store: Store(initialState: TermsOfServiceFeature.State(), reducer: TermsOfServiceFeature()))
    }
}


private let tocContent = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas egestas egestas condimentum. Sed nibh leo, ornare in dui in, pellentesque egestas massa. Nam imperdiet dui lorem, vitae mollis metus pretium eget. Nam sagittis mi bibendum urna consequat mollis. Aliquam ornare bibendum tortor ac posuere. Sed nec tortor arcu. Mauris tortor enim, porttitor ut mollis eu, tempus ultricies ex. Vivamus interdum augue purus, at feugiat est tempor in. Mauris pretium dolor lectus, ac tincidunt risus pulvinar nec. Pellentesque tempor magna at est laoreet, ut ultrices ex porta. Curabitur rutrum fermentum risus sit amet accumsan. Sed imperdiet nisl vitae quam mollis, non hendrerit purus facilisis.

Pellentesque tempus felis vitae augue placerat consectetur. Sed euismod metus in eros ultrices, vel tincidunt sapien dictum. In hac habitasse platea dictumst. Proin at leo et massa consequat porttitor nec id nunc. Nunc eleifend odio vel ex tincidunt, ut vulputate lacus feugiat. Quisque gravida sit amet lacus nec maximus. Sed molestie, nisi a consequat cursus, lectus dolor mattis lorem, sagittis pharetra nibh erat a tellus. Praesent ut libero at velit tristique rhoncus vitae ut enim.

Vivamus sed leo consectetur, iaculis ligula non, iaculis velit. Integer ac justo dui. Nulla mollis commodo nisl, non commodo dui commodo sed. In hac habitasse platea dictumst. Phasellus congue ultricies ante vitae blandit. Duis nec massa quis dolor auctor dignissim eget sit amet nulla. Nulla ultricies dictum tellus quis pharetra. Pellentesque sit amet urna mollis, auctor purus non, iaculis libero. Integer rhoncus molestie pharetra. Ut lorem est, auctor at blandit et, luctus eget ex. In sagittis faucibus magna sed rhoncus. Integer pharetra velit enim, sed lobortis dolor aliquam sit amet. In a tellus a diam euismod porta.

Donec suscipit est sit amet metus accumsan, et maximus urna gravida. Praesent vitae egestas turpis. Phasellus hendrerit ultricies ligula eu vehicula. Maecenas diam nulla, vestibulum vel vulputate sit amet, faucibus vel odio. Nunc bibendum justo quam, a finibus justo posuere eu. Sed id dolor non odio ultricies consequat ut sit amet diam. Sed euismod diam bibendum lorem gravida, ac fringilla tortor tincidunt. Curabitur ornare enim cursus sem hendrerit faucibus. Curabitur semper turpis eget ligula tempor, tincidunt hendrerit enim rutrum. Aliquam vel nunc eu lectus sollicitudin pharetra. Curabitur porta augue in feugiat feugiat.

Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer ornare dolor non metus convallis, vitae condimentum enim eleifend. Duis sed commodo risus, ut hendrerit massa. Nam vehicula, justo ultrices finibus laoreet, risus leo condimentum eros, ac eleifend erat neque vel tellus. Aliquam nec est et ante convallis vestibulum vitae ut eros. Fusce quis dolor nisl. Nullam dapibus elit nec nisi vulputate, eget varius ligula iaculis. Mauris in lorem a tortor efficitur cursus vel vitae neque. Sed eu tincidunt purus, eu dictum dolor. Nullam eu ultrices nisl. Nam a sem est. Aliquam volutpat magna viverra odio aliquam dapibus. Sed magna massa, molestie id dictum vel, commodo non massa. Sed aliquam pellentesque nisl. Donec consequat a tortor sit amet rutrum. Vivamus semper iaculis leo, a dictum dolor lobortis non.
"""
