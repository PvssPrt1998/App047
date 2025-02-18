import SwiftUI

struct Splash: View {
    
    @EnvironmentObject var source: Source
    @Binding var screen: Screen
    @AppStorage("firstLaunch") var firstLaunch = true
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(2, anchor: .center)
                .padding(.top, UIScreen.main.bounds.height * 0.75)
            
            Image("appicon1")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(.rect(cornerRadius: 40))
        }
        .onAppear {
            source.load { loaded in
                if loaded {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if firstLaunch {
                            firstLaunch = false
                            screen = .onboarding
                        } else {
                            screen = .main
                        }
                        
                    }
                }
            }
        }
    }
}

struct Splash_Preview: PreviewProvider {
    
    @State static var splash: Screen = .splash
    
    static var previews: some View {
        Splash(screen: $splash)
            .environmentObject(Source())
    }
}
