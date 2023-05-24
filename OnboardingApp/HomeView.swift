import SwiftUI
import ComposableArchitecture
import Combine

struct HomeFeature: ReducerProtocol {
    
    @Dependency(\.userPreferences) var userPreferences
    
    struct State: Equatable {
        var onboarding: OnboardingFeature.State?
        var main: MainFeature.State?
    }
    
    enum Action: Equatable {
        case start
        case showOnboarding
        case onboarding(OnboardingFeature.Action)
        case main(MainFeature.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                state.onboarding = nil
                do {
                    if let userDetails = try userPreferences.userDetails(),
                       let userCredentials = try userPreferences.userCredentials()
                    {
                        state.main = MainFeature.State(userDetails: userDetails, userCredentials: userCredentials)
                    } else {
                        return Effect.send(.showOnboarding)
                    }
                } catch {
                    // Cannot deserialise user's state.
                    // NOTE: This will happen when the app uses updated UserDetails/UserCredentials
                    // which cannot be deserialised ( no backwards compatibility)
                    // Simple solution: Erase the faulty data and force user to onboarding
                    userPreferences.eraseUserDetails()
                    userPreferences.eraseUserCredentials()
                }
                return .none
            case .showOnboarding:
                state.onboarding = OnboardingFeature.State()
                return .none
            case .onboarding(.finished):
                if let oboardingState = state.onboarding,
                   let userDetails = oboardingState.userDetails,
                   let email = oboardingState.email,
                   let password = oboardingState.password,
                   let pinCode = oboardingState.pinCode
                {
                    let userCredentials = UserCredentials(email: email, password: password, pinCode: pinCode)
                    do {
                        try userPreferences.setUserDetails(userDetails)
                        try userPreferences.setUserCredentials(userCredentials)
                    } catch {
                        fatalError("Cannot save user's state")
                    }
                } else {
                    // This scenario indicates a flow error
                    fatalError("Onboarding is finished but the data is incomplete")
                }
                
                return Effect.send(.start)
            case .onboarding:
                return .none
            case .main(.signOut):
                userPreferences.eraseUserDetails()
                userPreferences.eraseUserCredentials()
                state.main = nil
                return Effect.send(.start)
            case .main(.doLogIn):
                
                return .none
            case .main:
                return .none
            }
        }
        
        .ifLet(\.onboarding, action: /Action.onboarding) {
            OnboardingFeature()
        }
        
        .ifLet(\.main, action: /Action.main) {
            MainFeature()
        }
    }
}

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            VStack {
                IfLetStore(
                    self.store.scope(
                        state: \.main,
                        action: HomeFeature.Action.main
                    )
                ) {
                    MainView(store: $0)
                }
                
                IfLetStore(
                    self.store.scope(
                        state: \.onboarding,
                        action: HomeFeature.Action.onboarding
                    )
                ) {
                    OnboardingView(store: $0)
                }
            }
            .onAppear {
                viewStore.send(.start)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Store(initialState: HomeFeature.State(), reducer: HomeFeature()))
    }
}
