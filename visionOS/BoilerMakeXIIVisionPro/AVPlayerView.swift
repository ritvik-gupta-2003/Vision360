//
//  AVPlayerView.swift
//  BoilerMakeXIIVisionPro
//
//  Created by Ritvik Gupta on 2/22/25.
//

import SwiftUI

struct AVPlayerView: UIViewControllerRepresentable {
    let viewModel: AVPlayerViewModel

    func makeUIViewController(context: Context) -> some UIViewController {
        return viewModel.makePlayerViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Update the AVPlayerViewController as needed
    }
}
