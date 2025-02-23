import SwiftUI

struct LivestreamControlView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    Task {
                        appModel.videoPlayer?.pause()
                        appModel.videoPlayer = nil
                        appModel.selectedVideo = nil
                        openWindow(id: "MainWindow")
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        dismissWindow(id: "LivestreamControlWindow")
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
            
            Spacer()
        }
        .frame(width: 300, height: 100)
        .padding()
    }
}