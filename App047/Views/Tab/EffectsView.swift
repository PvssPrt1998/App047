import SwiftUI
import UIKit
import AVKit

struct EffectsView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @AppStorage("firstLaunchEffect") var firstLaunchEffect = true
    @Binding var screen: Screen
    @State var selection = 0
    @EnvironmentObject var source: Source
    
    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                TabView(selection: $selection) {
                    ForEach(0..<source.effects.count, id: \.self) { i in
                        VideoPlayer(player: avPlayer(url: source.effects[i].url))
                            //.frame(maxHeight: .infinity, alignment: .bottom)
                            .frame(width: UIScreen.main.bounds.size.height * 16 / 9, height: UIScreen.main.bounds.height)
                            .clipped()
                            .tag(i)
                            .ignoresSafeArea()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Text(source.effects[selection].title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(
                        Button {
                            withAnimation {
                                screen = .paywall
                            }
                        } label: {
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
                        }
                        .disabled(source.proSubscription)
                        .opacity(source.proSubscription ? 0 : 1)
                        ,alignment: .trailing
                    )
                    .padding(EdgeInsets(top: safeAreaInsets.top, leading: 16, bottom: 0, trailing: 16))
                    .frame(maxHeight: .infinity, alignment: .top)
                if firstLaunchEffect {
                    tip
                }
                
                Button {
                    source.effectId = source.effects[selection].id
                    print("effect Id \(source.effectId)")
                    withAnimation {
                        screen = .createWithPhoto
                    }
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.bgPrimary)
                            .frame(width: 32, height: 32)
                        Text("Use template")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.bgPrimary)
                    }
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 10))
                    .frame(height: 40)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 10))
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .background(LinearGradient(colors: [.bgPrimary.opacity(0), .bgPrimary], startPoint: .top, endPoint: .bottom).frame(height: 80), alignment: .bottom)
            }
            .ignoresSafeArea(.container, edges: .top)
    }
    
    private func avPlayer(url: String) -> AVPlayer {
        let player = AVPlayer(url: URL(string: url)!)
        player.play()
        return player
    }
    
    private var titleBySelection: String {
        switch selection {
        case 0: return "Hug and Kiss"
        case 1: return "Pop-It"
        case 2: return "Transformation"
        case 3: return "Default"
        default: return "Default"
        }
    }
    
    private var tip: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "hand.draw")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 44, height: 54)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Swipe to watch next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Watch clips nonstop")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
            
            Rectangle()
                .fill(Color.c606067.opacity(0.29))
                .frame(height: 0.5)
            
            Button {
                firstLaunchEffect = false
            } label: {
                Text("Got it!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.cSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
        .frame(width: 292)
        .background(Color.c373737.opacity(0.82))
        .clipShape(.rect(cornerRadius: 10))
    }
}

struct EffectsView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        EffectsView(screen: $screen)
            .environmentObject(Source())
    }
    
}
