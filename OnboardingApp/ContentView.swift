import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        HomeView(store: Store(initialState: HomeFeature.State(), reducer: HomeFeature()))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
