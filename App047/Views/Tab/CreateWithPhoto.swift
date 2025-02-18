import SwiftUI

struct CreateWithPhoto: View {
    
    @EnvironmentObject var source: Source
    @Binding var screen: Screen
    @State private var showingImagePicker = false
    @State var inputImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if inputImage != nil {
                    Image(uiImage: inputImage!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            Button {
                                showingImagePicker = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                    Text("Retake photo")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 141, height: 36)
                                .background(Color.black.opacity(0.32))
                                .clipShape(.rect(cornerRadius: 24))
                            }
                                .padding(.bottom, 8)
                            ,alignment: .bottom
                        )
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.7))
                        .padding(32)
                        .frame(maxHeight: .infinity)
                        .onTapGesture {
                            showingImagePicker = true
                        }
                }
                
                Button {
                    source.effectImage = inputImage
                    source.isEffect = true
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
                .opacity(inputImage == nil ? 0.6 : 1)
                .disabled(inputImage == nil)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
    }
    
    private var header: some View {
        Text("Create")
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
}

struct CreateWithPhoto_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        CreateWithPhoto(screen: $screen)
            .environmentObject(Source())
    }
}
