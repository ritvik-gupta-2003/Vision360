//
//  ImmersiveView.swift
//  BoilerMakeXIIVisionPro
//
//  Created by Ritvik Gupta on 2/22/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            guard let skyBox = generateSkyBox() else { return }
            content.add(skyBox)
        }
    }
    
    func generateVideoMaterial() -> VideoMaterial? {
        let url: URL?
        
        if appModel.selectedVideo == nil {
            // Livestream case - make sure we're using the livestream URL
            url = VideoDataManager.shared.getLivestreamURL()
            print("Loading livestream URL: \(url?.absoluteString ?? "nil")")
        } else {
            // Regular video case
            guard let video = appModel.selectedVideo,
                  let videoURL = VideoDataManager.shared.getVideoURL(fileName: video.fileName) else {
                print("Error loading video")
                return nil
            }
            url = videoURL
            print("Loading video URL: \(url?.absoluteString ?? "nil")")
        }
        
        guard let finalURL = url else {
            print("No valid URL found")
            return nil
        }
        
        // Reset any existing player
        if let existingPlayer = appModel.videoPlayer {
            existingPlayer.pause()
            existingPlayer.replaceCurrentItem(with: nil)
        }
        
        let avPlayer = AVPlayer(url: finalURL)
        let videoMaterial = VideoMaterial(avPlayer: avPlayer)
        appModel.videoPlayer = avPlayer
        avPlayer.play()
        
        return videoMaterial
    }
    
    func generateSkyBox() -> Entity? {
        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)
        
        guard let videoMaterial = generateVideoMaterial() else {
            return nil
        }
        
        let skyBoxEntity = ModelEntity(mesh: skyBoxMesh, materials: [videoMaterial])
        skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
        
        return skyBoxEntity
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
