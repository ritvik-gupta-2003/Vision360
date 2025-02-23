//
//  AppModel.swift
//  BoilerMakeXIIVisionPro
//
//  Created by Ritvik Gupta on 2/22/25.
//

import SwiftUI
import AVFoundation

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "VideoImmersiveView"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var videoPlayer: AVPlayer?
    var selectedVideo: Video?
    var showVideoList = false
    var showVideoControls = false
}
