import SwiftUI

struct Tab: View {
    
    @EnvironmentObject var source: Source
    @State var selection = 0
    @Binding var screen: Screen
    
    init(screen: Binding<Screen>) {
        self._screen = screen
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(rgbColorCodeRed: 254, green: 117, blue: 251, alpha: 1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.cPrimary]
        appearance.backgroundColor = UIColor.bgPrimary
        appearance.shadowColor = .white.withAlphaComponent(0.15)
        appearance.shadowImage = UIImage(named: "tab-shadow")?.withRenderingMode(.alwaysTemplate)
        UITabBar.appearance().backgroundColor = UIColor.bgPrimary
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $selection) {
                    EffectsView(screen: $screen)
                        .tabItem { VStack {
                            tabViewImage("house.fill")
                            Text("Effects").font(.system(size: 10, weight: .medium))
                        } }
                        .tag(0)
                    PromtView(screen: $screen)
                        .tabItem { VStack {
                            tabViewImage("sparkles")
                            Text("Promts").font(.system(size: 10, weight: .medium))
                        } }
                        .tag(1)
                    HistoryView(screen: $screen)
                        .tabItem {
                            VStack {
                                tabViewImage("folder.fill")
                                Text("My projects") .font(.system(size: 10, weight: .medium))
                            }
                        }
                        .tag(2)
                    SettingsView(screen: $screen)
                        .tabItem {
                            VStack {
                                tabViewImage("gearshape.fill")
                                Text("Settings") .font(.system(size: 10, weight: .medium))
                            }
                        }
                        .tag(3)
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                    .padding(.bottom, UITabBarController().height)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
    
//    @ViewBuilder var generateView: some View {
//        switch tabScreen {
//        case .generationChoice:
//            GenerationChoice(screen: $tabScreen)
//        case .videoImageGenerator:
//            VideoImageGenerator(screen: $tabScreen)
//        case .videoResult:
//            GenerationResult(screen: $tabScreen)
//        case .promtResult:
//            PromtGenerationView(screen: $tabScreen)
//        }
//    }
    
    @ViewBuilder func tabViewImage(_ systemName: String) -> some View {
        if #available(iOS 15.0, *) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .environment(\.symbolVariants, .none)
        } else {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
        }
    }
}

struct Tab_Preview: PreviewProvider {

    @State static var screen: Screen = .main

    static var previews: some View {
        Tab(screen: $screen)
            .environmentObject(Source())
    }
}

extension UIColor {
   convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {

     let redPart: CGFloat = CGFloat(red) / 255
     let greenPart: CGFloat = CGFloat(green) / 255
     let bluePart: CGFloat = CGFloat(blue) / 255

     self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
   }
}

extension UITabBarController {
    var height: CGFloat {
        return self.tabBar.frame.size.height
    }
    
    var width: CGFloat {
        return self.tabBar.frame.size.width
    }
}
