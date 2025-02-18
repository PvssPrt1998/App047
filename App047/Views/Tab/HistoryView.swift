import SwiftUI
import AVKit

struct HistoryView: View {
    
    @Binding var screen: Screen
    @EnvironmentObject var source: Source
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("My projects")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                
                if !source.videoIDs.isEmpty {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8, content: {
                            ForEach(source.videoIDs, id: \.self) { video in
                                videoCard(video)
                            }
                        })
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    }
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: "rectangle.stack.badge.play.fill")
                            .font(.system(size: 34, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 64, height: 64)
                        VStack(spacing: 6) {
                            Text("No Videos")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Create your first adorable video\nand surprise everyone!")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    @ViewBuilder private func videoCard(_ video: Video) -> some View {
        if let str = video.url, let url = URL(string: str) {
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 156)
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    Text(video.date ?? "")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                        .padding(10)
                    ,alignment: .bottomLeading
                )
                .overlay(
                    Menu("\(Image(systemName: "ellipsis"))") {
                        Button {
                            saveToGallery()
                        } label: {
                            Label("Save to gallery", systemImage: "arrow.down.to.line")
                        }
                        
                        Divider()

                        Button {
                            source.removeVideo(video.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                    }
                        .font(.system(size: 17, weight: .regular))
                                                .foregroundColor(.white.opacity(0.8))
                        .frame(width: 32, height: 32)
                        .background(Color.c373737.opacity(0.55))
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(10)
                    ,alignment: .topTrailing
                )
        } else {
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 156)
                .overlay(ProgressView().progressViewStyle(.circular))
                .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    private func saveToGallery() {
        if let url = source.localUrl {
            source.saveVideoToAlbum(videoURL: url, albumName: "Generated videos") {
            } completion: {
            }
        } else {
            
        }
    }
}

struct HistoryView_Preview: PreviewProvider {
    
    @State static var screen: Screen = .onboarding
    
    static var previews: some View {
        HistoryView(screen: $screen)
            .environmentObject(Source())
    }
}
