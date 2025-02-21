import SwiftUI
import ApphudSDK

struct PaywallView: View {
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var source: Source
    @Binding var screen: Screen
    @State var isYear = true
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            Image("PaywallImage")
                .scaledToFit()
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                titleAndSubtitle
                selection
                    .padding(.top, 28)
                    .background(Color.bgPrimary)
                bottomBar
                    .padding(.horizontal, 16)
                    .background(Color.bgPrimary)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            Button {
                withAnimation {
                    screen = .main
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.32))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 24, height: 24)
                Text("Cancel Anytime")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(height: 40)
            
            Button {
                source.startPurchase(product: isYear ? source.productsApphud[0] : source.productsApphud[1]) { bool in
                    if bool {
                        print("Subscription purchased")
                        source.proSubscription = true
                    }
                    withAnimation {
                        screen = .main
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.vertical, 2)
            
            HStack(spacing: 12) {
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/11XBfYAuGvIj-tq7o22zMtqbmjH_Wp_ZZKU2ODwqwvDE/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                Button {
                    source.restorePurchase { bool in
                        if bool {
                            source.proSubscription = false
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Button {
                    if let url = URL(string: "https://docs.google.com/document/d/15LA8Q663un3E44lI3jLHCgTHBGcHevze_a66ZcXkUUQ/edit?usp=sharing") {
                        openURL(url)
                    }
                } label: {
                    Text("Terms of Use")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 12, trailing: 0))
        }
    }
    
    private var titleAndSubtitle: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Image(systemName: "crown")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                Text("PRO")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 79, height: 32)
            .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing))
            .clipShape(.rect(cornerRadius: 10))
            VStack(spacing: 8) {
                Text("Even more possibilities\nfor video creation")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .italic()
                    .multilineTextAlignment(.center)
                Text("Unlock all features with Pro")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(stops: [.init(color: Color.bgPrimary.opacity(0), location: 0), .init(color: .bgPrimary, location: 0.8)], startPoint: .top, endPoint: .bottom)
        )
    }
    
    private var selection: some View {
        VStack(spacing: 8) {
            annual
            week
        }
        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
        .background(Color.bgPrimary)
    }
    
    private var week: some View {
        HStack(spacing: 8) {
            Image(systemName: !isYear ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(!isYear ? .cPrimary : .white.opacity(0.28))
                .frame(width: 32, height: 32)
            Text(source.returnName(product: source.productsApphud[0]))
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 0) {
                Text(source.returnPriceSign(product: source.productsApphud[0]) + source.returnPrice(product: source.productsApphud[0]))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(" / week")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .frame(height: 56)
        .background(Color.white.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(!isYear ?
                        LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing), lineWidth: 1
                )
        )
        .onTapGesture {
            isYear = false
        }
    }
    
    private var annual: some View {
        HStack(spacing: 8) {
            Image(systemName: isYear ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(isYear ? .cPrimary : .white.opacity(0.28))
                .frame(width: 32, height: 32)
            VStack(alignment: .leading , spacing: 2) {
                Text(source.returnName(product: source.productsApphud[1]))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                Text(source.returnPriceSign(product: source.productsApphud[1]) + "\(Double(String(format: "%.2f", getSubscriptionPrice(for: source.productsApphud[1]) / 52)) ?? 0.0)" + " per week")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 0) {
                Text(source.returnPriceSign(product: source.productsApphud[1]) + source.returnPrice(product: source.productsApphud[1]))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(" / year")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .frame(height: 56)
        .background(Color.white.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isYear ?
                        LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing), lineWidth: 1
                )
        )
        .onTapGesture {
            isYear = true
        }
        .frame(height: 80)
        .overlay(
            Text("Save 40%")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 66, height: 21)
                .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .top, endPoint: .bottom))
                .clipShape(.rect(cornerRadius: 4))
                .padding(.horizontal, 16)
            
            ,alignment: .topTrailing
        )
    }
    
    private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
        if let price = product.skProduct?.price {
            return Double(truncating: price)
        } else {
            return 0
        }
    }
}

struct PaywallView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        PaywallView(screen: $screen)
            .environmentObject(Source())
    }
    
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
