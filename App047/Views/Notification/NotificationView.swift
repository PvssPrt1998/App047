import SwiftUI

struct NotificationView: View {
    
    @Binding var screen: Screen
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image("OnboardingImage5")
                .resizable()
                .scaledToFit()
                //.padding(EdgeInsets(top: 0, leading: 16, bottom: 250, trailing: 16))
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.container, edges: .top)
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Don't miss new trends ⭐")
                        .font(.system(size: 28, weight: .semibold))
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Allow notifications")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 88)
                .frame(maxHeight: .infinity)
                .frame(height: 166)
                .background(
                    LinearGradient(colors: [.bgPrimary.opacity(0), .bgPrimary], startPoint: .top, endPoint: .bottom)
                )
                
                VStack(spacing: 8) {
                    Button {
                        registerForNotification()
                        withAnimation {
                            screen = .paywall
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
                    Button {
                        withAnimation {
                            screen = .paywall
                        }
                    } label: {
                        Text("Maybe later")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                        
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 32, trailing: 0))
            .frame(height: 250)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
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
}

struct NotificationView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        NotificationView(screen: $screen)
            .environmentObject(Source())
    }
    
}
