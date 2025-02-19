import SwiftUI
import AVKit

struct ResultView: View {
    
    @State private var player = AVPlayer()
    @EnvironmentObject var source: Source
    @Binding var screen: Screen
    @State var isLoading = true
    
    @State var savedToGalleryAlert = false
    @State var notSavedToGalleryAlert = false
    
    @State var rotationValue: Double = 0
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 32) {
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 4)
                        .frame(width: 160, height: 160)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.3)
                                .stroke(Color.cPrimary, lineWidth: 4)
                                .rotationEffect(.degrees(rotationValue))
                                .frame(width: 160, height: 160)
                        )
                    
                    VStack(spacing: 12) {
                        Text("Generating your video...")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Please do not close until your video\nis created. This may take up to a minute.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationValue = 360
                    }
                }
                
                Button {
                    withAnimation {
                        screen = .createWithPhoto
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.05))
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            } else {
                VStack(spacing: 0) {
                    header
                    VideoPlayer(player: player)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding(16)
                        .frame(maxHeight: .infinity)
                    
                    Button {
                        saveToGallery()
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                            Text("Save to gallery")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(LinearGradient(colors: [.gradientColor1, .gradientColor2], startPoint: .leading, endPoint: .trailing))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .alert(isPresented: $savedToGalleryAlert) {
                    Alert(
                        title: Text("Video saved to gallery")
                    )
                }
        .alert(isPresented: $notSavedToGalleryAlert, content: {
            Alert(
                title: Text("Error, video not saved to gallery"),
                message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                primaryButton: .destructive(Text("Cancel"), action: {
                    notSavedToGalleryAlert = false
                }),
                secondaryButton: .default(Text("Try again"), action: {
                    saveToGallery()
                    notSavedToGalleryAlert = false
                })
            )
        })
        .onAppear {
            if !source.preventDouble {
                source.preventDouble = true
                if source.isEffect {
                    generateByImage()
                } else {
                    generate()
                }
            }
        }
    }
    
    private func isGenerationFinished(id: String) {
        source.isGenerationFinished(id: id) { isFinished in
            if isFinished {
                source.videoById(id: id) { url in
                    source.saveUrl(id: id, url: url.absoluteString)
                    source.currentVideoId = id
                    isLoading = false
                    player = AVPlayer(url: url)
                } errorHandler: {
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (source.proSubscription ? 30 : 45)) {
                    isGenerationFinished(id: id)
                }
            }
        } errorHandler: {
            
        }
    }
    
    func generate() {
        guard let promt = source.promts else { return }
        source.textToVideo(text: promt) {

        } completion: { id in
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                isGenerationFinished(id: id)
            }
        }
    }
    
    private func saveToGallery() {
        if let url = source.localUrl {
            source.saveVideoToAlbum(videoURL: url, albumName: "Generated videos") {
                withAnimation {
                    notSavedToGalleryAlert = true
                }
            } completion: {
                withAnimation {
                    savedToGalleryAlert = true
                }
            }

        } else {
            withAnimation {
                notSavedToGalleryAlert = true
            }
        }
    }
    
    private var header: some View {
        Text("Result")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .overlay(
                Button {
                    screen = .createWithPhoto
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
    
    func generateByImage() {
        print("IN generate effectId")
        print(source.effectId)
        source.generateEffect(userId: UIDevice.current.identifierForVendor?.uuidString ?? "User \(UUID().uuidString)", appId: "com.iri.m1n1m4x41vg") { id in
            isImageGenerationFinished(id: id)
            print(id)
        } errorHandler: {
            
        }
        //source.getEffectURLById(id: "df272baf-c75c-4584-a60b-8d87b15bfeaf")
    }
    
    private func isImageGenerationFinished(id: String) {
        source.getEffectURLById(id: id) { url, isDone in
            if isDone && url != nil {
                source.saveUrl(id: id, url: url!.absoluteString)
                source.currentVideoId = id
                isLoading = false
                let playerTMP = AVPlayer(url: url!)
                playerTMP.externalPlaybackVideoGravity = .resizeAspect
                player = playerTMP
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (source.proSubscription ? 30 : 45)) {
                    isImageGenerationFinished(id: id)
                }
            }
        } errorHandler: {
            
        }
    }
}

struct ResultView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .result
    
    static var previews: some View {
        ResultView(screen: $screen)
            .environmentObject(Source())
    }
}
