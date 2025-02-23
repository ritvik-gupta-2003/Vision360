import SwiftUI

@main
struct BoilerMakeXIIVisionProApp: App {
	@State private var appModel = AppModel()
	@State private var modelState = ModelState()
	@State private var currentStyle: ImmersionStyle = .full
	
	// Height modifier for the volumetric window
	let heightModifier: CGFloat = 1
	
	var body: some Scene {
		WindowGroup(id: "MainWindow") {
			ContentView()
				.environment(appModel)
				.environment(modelState)
		}
		
		WindowGroup(id: "3DModelWindow", for: URL.self) { $url in
			ModelView(usdzFileURL: url ?? URL(fileURLWithPath: ""))
				.environment(appModel)
				.environment(modelState)
		}
		.windowStyle(.volumetric)
		.defaultSize(
			width: ModelView.defaultSize,
			height: heightModifier * ModelView.defaultSize,
			depth: ModelView.defaultSize,
			in: .inches
		)
		
		WindowGroup(id: "VideoControlWindow") {
			VideoControlView()
				.environment(appModel)
		}
		.defaultSize(width: 400, height: 180)
		.windowStyle(.plain)
		
		ImmersiveSpace(id: "VideoImmersiveView") {
			ImmersiveView()
				.environment(appModel)
		}
		.immersionStyle(selection: $currentStyle, in: .full)
		
		WindowGroup(id: "LivestreamControlWindow") {
			LivestreamControlView()
				.environment(appModel)
		}
		.defaultSize(width: 300, height: 100)
		.windowStyle(.plain)
	}
}
