import SwiftUI

enum Screen {
    case splash
    case onboarding
    case notification
    case paywall
    case main
    case createWithPhoto
    case result
}

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

//Аккаунт: nishaowyd@gmail.com
//Пароль: Joshua321.
//Bundle ID: com.iri.m1n1m4x41vg
//Policy: https://docs.google.com/document/d/11XBfYAuGvIj-tq7o22zMtqbmjH_Wp_ZZKU2ODwqwvDE/edit?usp=sharing
//Terms: https://docs.google.com/document/d/15LA8Q663un3E44lI3jLHCgTHBGcHevze_a66ZcXkUUQ/edit?usp=sharing
//App URL: https://apps.apple.com/us/app/minimax-ai-video-generator/id6742104809
