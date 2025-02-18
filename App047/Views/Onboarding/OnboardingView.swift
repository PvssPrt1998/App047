import SwiftUI
import StoreKit

struct OnboardingView: View {
    @State var selection = 0
    //@Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var screen: Screen
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selection) {
                onboardingImage("OnboardingImage1")
                    .tag(0)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("OnboardingImage2")
                    .tag(1)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("OnboardingImage3")
                    .tag(2)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
                onboardingImage("OnboardingImage4")
                    .tag(3)
                    .gesture(DragGesture())
                    .ignoresSafeArea()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .gesture(DragGesture())
            .overlay(
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text(titleForSelection)
                                .font(.system(size: 28, weight: .semibold))
                                .italic()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text(descriptionForSelection)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 88)
                        .frame(maxWidth: .infinity)
                        .frame(height: 166)
                        .background(
                            LinearGradient(colors: [.bgPrimary.opacity(0), .bgPrimary], startPoint: .top, endPoint: .bottom)
                        )
                        
                        VStack(spacing: 8) {
                            Button {
                                if selection == 2 {
                                    SKStoreReviewController.requestReviewInCurrentScene()
                                }
                                if selection < 3 {
                                    withAnimation {
                                        selection += 1
                                    }
                                } else {
                                    withAnimation {
                                        screen = .notification
                                    }
                                }
                            } label: {
                                Text("Continue")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
                            indicators
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 32, trailing: 0))
                    .frame(height: 250)
                }
                
                ,alignment: .bottom
            )
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    private func onboardingImage(_ title: String) -> some View {
        Image(title)
            .resizable()
            .scaledToFit()
            //.padding(EdgeInsets(top: 0, leading: 16, bottom: 250, trailing: 16))
            .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var indicators: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selection == 0 ? Color.white : Color.white.opacity(0.3))
            Circle()
                .fill(selection == 1 ? Color.white : Color.white.opacity(0.3))
            Circle()
                .fill(selection == 2 ? Color.white : Color.white.opacity(0.3))
            Circle()
                .fill(selection == 3 ? Color.white : Color.white.opacity(0.3))
        }
        .frame(height: 8)
        .frame(height: 44)
    }
    
    func registerForNotification() {
            //For device token and push notifications.
            UIApplication.shared.registerForRemoteNotifications()
            
            let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
            //        center.delegate = self
            
            center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
                if ((error != nil)) { UIApplication.shared.registerForRemoteNotifications() }
                else {
                    
                }
            })
        }
    
    private var titleForSelection: String {
        switch selection {
        case 0: return "Welcome to our AI app 🔥"
        case 1: return "Large effects collection ❤"
        case 2: return "Make up your own videos 🤩"
        case 3: return "Your feedback is very\nimportant ⭐"
        default: return "Don't miss new trends ⭐"
        }
    }
    
    private var descriptionForSelection: String {
        switch selection {
        case 0: return "Hundreds of AI patterns are waiting for you"
        case 1: return "Choose from a variety of impressive effects"
        case 2: return "Make up original text promts for your videos"
        case 3: return "Rate us in the AppStore"
        default: return "Allow notifications"
        }
    }
}

struct OnboardingView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        OnboardingView(screen: $screen)
            .environmentObject(Source())
    }
    
}
