import SwiftUI

struct OnboardingPageView<MainContent: View, BottomContent: View>: View {
    
    let mainContent: MainContent
    let bottomContent: BottomContent
    
    init(@ViewBuilder mainContent: () -> MainContent, @ViewBuilder bottomContent: () -> BottomContent) {
        self.mainContent = mainContent()
        self.bottomContent = bottomContent()
    }
    
    var body: some View {
        VStack {
            mainContent
                .padding()
            Spacer()
            bottomContent
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView() {
            Text("Main Content. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed varius vel nisl in semper. Cras vel elit tellus. Suspendisse vel massa sed purus euismod tincidunt eu vel eros. Donec condimentum vel dui quis rutrum. Fusce ipsum tellus, sagittis in libero a, finibus ultrices odio. Fusce in nisl tempus ex rhoncus elementum. Ut molestie ipsum vitae lacus consectetur, vel auctor massa congue. Suspendisse pharetra ornare felis, vitae pharetra diam egestas in. Nullam faucibus orci vitae nisi eleifend laoreet.")
        } bottomContent: {
            Text("Bottom Content")
        }

    }
}
