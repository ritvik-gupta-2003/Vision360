import SwiftUI
import AVKit

struct VideoControlView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @State private var isPlaying = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            // Back button row
            HStack {
                Button(action: {
                    Task {
                        appModel.videoPlayer?.pause()
                        appModel.videoPlayer = nil
                        openWindow(id: "MainWindow")
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        dismissWindow(id: "VideoControlWindow")
                        appModel.showVideoList = true
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back to Videos")
                    }
                    .padding()
                }
                Spacer()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            
            // Video controls with more horizontal space
            HStack(spacing: 20) {
                Button(action: {
                    if isPlaying {
                        appModel.videoPlayer?.pause()
                    } else {
                        appModel.videoPlayer?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                VStack(spacing: 8) {
                    if duration > 0 {
                        Slider(value: Binding(
                            get: { currentTime },
                            set: { newValue in
                                currentTime = newValue
                                appModel.videoPlayer?.seek(to: CMTime(seconds: newValue, preferredTimescale: 600))
                            }
                        ), in: 0...max(1, duration))
                        .accentColor(.white)
                    }
                    
                    HStack {
                        Text(formatTime(currentTime))
                            .font(.caption)
                        Spacer()
                        Text(formatTime(duration))
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
        .frame(width: 400, height: 180)
        .padding()
        .onAppear {
            if let player = appModel.videoPlayer {
                let dur = player.currentItem?.duration.seconds ?? 0
                duration = dur.isFinite ? dur : 0
            }
        }
        .onReceive(timer) { _ in
            if let player = appModel.videoPlayer {
                currentTime = player.currentTime().seconds
                isPlaying = player.timeControlStatus == .playing
                
                if duration <= 1 {
                    let dur = player.currentItem?.duration.seconds ?? 0
                    if dur.isFinite && dur > 0 {
                        duration = dur
                    }
                }
            }
        }
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}