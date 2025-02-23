import SwiftUI
import RealityKit
import UniformTypeIdentifiers
import UIKit

// MARK: - States
@Observable class ModelState {
	var usdzFileURL: URL?
	var textFileContent: String?
	var show3DView = false
	var showModelList = false  // New state for showing model list
}

// MARK: - Content View
struct ContentView: View {
	@Environment(ModelState.self) var modelState
	@Environment(AppModel.self) var appModel
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismissWindow) private var dismissWindow
	@Environment(\.openImmersiveSpace) private var openImmersiveSpace
	@Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
	
	var body: some View {
		VStack {
			if appModel.showVideoList {
				// Video List View
				VStack {
					HStack {
						Button(action: {
							appModel.showVideoList = false
						}) {
							Text("Back to Menu")
								.foregroundColor(.blue)
								.padding()
						}
						Spacer()
					}
					
					ScrollView {
						LazyVStack(spacing: 20) {
							// Livestream button at the top
							Button(action: {
								Task {
									// Clear any selected video before starting livestream
									appModel.selectedVideo = nil
									// Open immersive space first
									appModel.immersiveSpaceState = .inTransition
									switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
										case .opened:
											dismissWindow(id: "MainWindow")
											appModel.showVideoList = false
											// Use a different window for livestream controls
											openWindow(id: "LivestreamControlWindow")
											break
										case .userCancelled, .error:
											fallthrough
										@unknown default:
											appModel.immersiveSpaceState = .closed
									}
								}
							}) {
								Text("Livestream")
									.frame(maxWidth: .infinity)
									.padding()
							}
							
							ForEach(VideoDataManager.shared.videos) { video in
								Button(action: {
									appModel.selectedVideo = video
									Task {
										// Open immersive space first
										appModel.immersiveSpaceState = .inTransition
										switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
											case .opened:
												// Only dismiss main window after immersive space is open
												dismissWindow(id: "MainWindow")
												appModel.showVideoList = false
												openWindow(id: "VideoControlWindow")
												break
											case .userCancelled, .error:
												fallthrough
											@unknown default:
												appModel.immersiveSpaceState = .closed
										}
									}
								}) {
									Text(video.name)
										.frame(maxWidth: .infinity)
										.padding()
										.cornerRadius(10)
								}
							}
						}
						.padding()
					}
				}
				.padding()
			} else if modelState.show3DView {
				// Main window shows only text content
				VStack {
					HStack {
						Button(action: {
							dismissWindow(id: "3DModelWindow")
							modelState.show3DView = false
							modelState.usdzFileURL = nil
							modelState.textFileContent = nil
							modelState.showModelList = false // Reset model list state
						}) {
							Text("Back")
								.foregroundColor(.blue)
								.padding()
						}
						Spacer()
					}

					if let textContent = modelState.textFileContent {
						ScrollView {
							Text(textContent)
								.padding()
						}
					}
				}
				.padding()
				.onAppear {
					if let url = modelState.usdzFileURL {
						openWindow(id: "3DModelWindow", value: url)
					}
				}
			} else if modelState.showModelList {
				// Model List View
				VStack {
					HStack {
						Button(action: {
							modelState.showModelList = false
						}) {
							Text("Back to Menu")
								.foregroundColor(.blue)
								.padding()
						}
						Spacer()
					}
					
					ScrollView {
						LazyVStack(spacing: 20) {
							ForEach(ModelDataManager.shared.models) { model in
								Button(action: {
									loadModel(model)
								}) {
									Text(model.name)
										.frame(maxWidth: .infinity)
										.padding()
										.cornerRadius(10)
								}
							}
						}
						.padding()
					}
				}
				.padding()
			} else {
				// Main UI - Home Screen
				HStack {
					Button(action: { modelState.showModelList = true }) {
						Text("Photo Mode")
							.frame(maxWidth: .infinity)
							.padding()
					}
					.frame(maxWidth: .infinity)

					Button(action: { appModel.showVideoList = true }) {
						Text("Video Mode")
							.frame(maxWidth: .infinity)
							.padding()
					}
					.frame(maxWidth: .infinity)
				}
				.padding()
			}
		}
	}
	
	private func loadModel(_ model: Model) {
		if let usdzURL = ModelDataManager.shared.getModelURL(fileName: model.usdzFileName) {
			modelState.usdzFileURL = usdzURL
			modelState.textFileContent = ModelDataManager.shared.getModelText(fileName: model.textFileName)
			modelState.show3DView = true
		}
	}
}

// MARK: - 3D Model View
struct ModelView: View {
	let usdzFileURL: URL
	@Environment(ModelState.self) var modelState
	
	// Default size for the volumetric window
	static let defaultSize: CGFloat = 10
	
	var body: some View {
		GeometryReader3D { geometry in
			RealityView { content in
				do {
					let entity = try Entity.load(contentsOf: usdzFileURL)
					content.add(entity)
					
					// Get the view bounds in the scene coordinate space
					let viewBounds = content.convert(
						geometry.frame(in: .local),
						from: .local,
						to: .scene
					)
					
					// Position the model at the bottom of the visual bounding box
					entity.position.y -= entity.visualBounds(relativeTo: nil).min.y
					entity.position.y += viewBounds.min.y
					
					// Scale the model to fit the window
					let baseExtents = entity.visualBounds(relativeTo: nil).extents / entity.scale
					let scale = Float(viewBounds.extents.x) / baseExtents.x
//					entity.scale = SIMD3<Float>(repeating: scale)
					
				} catch {
					print("Error loading USDZ file: \(error.localizedDescription)")
				}
			}
			.gesture(
				DragGesture()
					.targetedToAnyEntity()
			)
		}
	}
}

// MARK: - Folder Picker
struct FolderPicker: UIViewControllerRepresentable {
	@Environment(ModelState.self) var modelState
	
	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	class Coordinator: NSObject, UIDocumentPickerDelegate {
		let parent: FolderPicker

		init(_ parent: FolderPicker) {
			self.parent = parent
		}

		func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
			guard let folderURL = urls.first else { return }
			
			let fileManager = FileManager.default
			do {
				let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

				if let usdzURL = fileURLs.first(where: { $0.pathExtension == "usdz" }) {
					parent.modelState.usdzFileURL = usdzURL
				}

				if let textFileURL = fileURLs.first(where: { $0.pathExtension == "txt" }) {
					parent.modelState.textFileContent = try String(contentsOf: textFileURL, encoding: .utf8)
				}

				if parent.modelState.usdzFileURL != nil {
					parent.modelState.show3DView = true
				}
			} catch {
				print("Error loading folder contents: \(error.localizedDescription)")
			}
		}
	}
}
