import SwiftUI

struct PromtView: View {
    
    @EnvironmentObject var source: Source
    @Binding var screen: Screen
    
    @State var text = ""
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                textEditorCustom(text: $text, placeholder: "Describe what kind of video you want")
                    .padding(16)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                Button {
                    source.preventDouble = false
                    source.promts = text
                    print(source.promts)
                    source.isEffect = false
                    withAnimation {
                        screen = .result
                    }
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                        Text("Generate")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .opacity(text == "" ? 0.6 : 1)
                .disabled(text == "")
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    private var header: some View {
        Text("Promts")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .overlay(
                Button {
                    withAnimation {
                        screen = .main
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Back")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                ,alignment: .leading
            )
    }
    
    func placeholderView(isShow: Bool, text: String) -> some View {
        Text(isShow ? text : "")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.white.opacity(0.6))
            .padding(EdgeInsets(top: 23, leading: 16, bottom: 15, trailing: 16))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    @ViewBuilder private func textEditorCustom(text: Binding<String>, placeholder: String) -> some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .padding(EdgeInsets(top: 15, leading: 12, bottom: 40, trailing: 12))
                .background(
                    placeholderView(isShow: text.wrappedValue == "", text: placeholder)
                )
                .padding(0)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .background(Color.bgSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .frame(height: 144)
        } else {
            TextEditor(text: $text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 15, leading: 12, bottom: 40, trailing: 12))
                .background(
                    placeholderView(isShow: text.wrappedValue == "", text: placeholder)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .background(Color.bgSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .frame(height: 144)
        }
    }
}

struct PromtView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        PromtView(screen: $screen)
            .environmentObject(Source())
    }
}
