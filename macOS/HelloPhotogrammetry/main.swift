import RealityKit
import Foundation
import AppKit  // Needed for Quick Look

let inputFolderUrl = URL(fileURLWithPath: "/Users/beastgupta/Actual Stuff/XCode/BoilerMake XII/PhotogrammetrySampleCode/HelloPhotogrammetry/Coke Can Capture", isDirectory: true)
let outputModelUrl = URL(fileURLWithPath: "/Users/beastgupta/Actual Stuff/XCode/3D Outputs/coke-can-model.usdz")

print("🚀 Starting Photogrammetry Session...")

// Check if Object Capture is supported
guard PhotogrammetrySession.isSupported else {
	print("❌ Error: Object Capture is not available on this Mac.")
	exit(1)
}

do {
	let session = try PhotogrammetrySession(
		input: inputFolderUrl,
		configuration: PhotogrammetrySession.Configuration()
	)

	try session.process(requests: [
		.modelFile(url: outputModelUrl, detail: .full)  // High quality model
	])

	// ✅ Keeps the program running while processing
	let processingTask = Task {
		do {
			for try await output in session.outputs {
				switch output {
				case .requestProgress(_, let fractionComplete):
					print("🔄 Progress: \(Int(fractionComplete * 100))%")

				case .requestComplete(_, let result):
					if case .modelFile(let url) = result {
						print("✅ Model saved at: \(url)")

						// Open model in Quick Look
						NSWorkspace.shared.open(url)
					}

				case .requestError(_, let error):
					print("❌ Error: \(error)")

				case .processingComplete:
					print("🎉 Processing Complete!")
					exit(0) // Exits the app after successful processing

				default:
					break
				}
			}
		} catch {
			print("❌ Error processing outputs: \(error)")
			exit(1)
		}
	}

	// Keeps the script running so `Task {}` can finish processing
	RunLoop.main.run()

} catch {
	print("❌ Failed to create PhotogrammetrySession: \(error)")
	exit(1)
}
