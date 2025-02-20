import OSLog
import PhotosUI
import SwiftUI

struct CameraContainerView: View {
    @StateObject private var camera = CameraService()
    @StateObject private var analysisService: ImageAnalysisService
    @State private var isAskViewPresented = false
    @State private var questionText = ""
    @State private var selectedItem: PhotosPickerItem?

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "CameraContainerView")

    init() {
        let vlmService = VLMService()
        _analysisService = StateObject(
            wrappedValue: ImageAnalysisService(vlmService: vlmService))
    }

    var body: some View {
        ZStack {
            CameraView(camera: camera)
                .ignoresSafeArea()

            if isAskViewPresented {
                AskView(
                    isAskViewPresented: $isAskViewPresented,
                    questionText: $questionText)
            }

            VStack {
                Spacer()
                BottomControlsView(
                    isAskViewPresented: $isAskViewPresented,
                    selectedItem: $selectedItem,
                    camera: camera,
                    analysisService: analysisService)
            }

            if let result = analysisService.analysisResult {
                ResultView(result: result)
                    .padding(.top)
                    .padding()
                    .animation(
                        .easeInOut(duration: 0.5),
                        value: analysisService.isAnalyzing)
            }

            if analysisService.isAnalyzing {
                LoadingImageView()
                    .animation(
                        .easeInOut(duration: 0.5),
                        value: analysisService.isAnalyzing)
            }
        }
        .onChange(of: selectedItem) { item in
            Task {
                logger.info("Processing picked photo")
                if let data = try? await item?.loadTransferable(
                    type: Data.self),
                    let image = UIImage(data: data)
                {
                    logger.debug(
                        "Successfully loaded image from picker, starting analysis"
                    )
                    analysisService.analyzeImage(image)
                } else {
                    logger.error("Failed to load picked photo data")
                }
            }
        }
    }
}

struct AskView: View {
    @Binding var isAskViewPresented: Bool
    @Binding var questionText: String

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Logo
                Image(systemName: "camera.aperture")
                    .font(.title2)
                    .foregroundStyle(.gray)

                TextField("Ask about details...", text: $questionText)
                    .foregroundStyle(.primary)

                Button(action: {
                    isAskViewPresented = false
                    questionText = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
        }
        .background(Color.black.opacity(0.001))
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.black
            .ignoresSafeArea()

        AskView(
            isAskViewPresented: .constant(true),
            questionText: .constant(""))
    }
}

struct AskButton: View {
    @Binding var isAskViewPresented: Bool

    var body: some View {
        Button(action: {
            isAskViewPresented.toggle()
        }) {
            Image(systemName: "text.bubble")
                .font(.system(size: 24))
                .foregroundStyle(Color.white.gradient)
                .padding()
                .background(Color.secondary.gradient)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.black
            .ignoresSafeArea()

        AskButton(isAskViewPresented: .constant(false))
    }
}

struct BottomControlsView: View {
    @Binding var isAskViewPresented: Bool
    @Binding var selectedItem: PhotosPickerItem?
    let camera: CameraService
    let analysisService: ImageAnalysisService
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.smollens",
        category: "BottomControlsView")

    var body: some View {
        VStack {
            Spacer()

            HStack {
                AskButton(isAskViewPresented: $isAskViewPresented)
                    .padding(.leading)

                Spacer()

                CameraControlsView(isCaptured: camera.isCaptured) {
                    if camera.isCaptured {
                        logger.debug("Resetting camera for new capture")
                        camera.reset()
                        analysisService.reset()
                    } else {
                        logger.info("Initiating photo capture sequence")
                        camera.capturePhoto {
                            if let image = camera.capturedImage {
                                analysisService.analyzeImage(image)
                            }
                        }
                    }
                }

                Spacer()

                LibraryButton(selectedItem: $selectedItem)
                    .padding(.trailing)
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    BottomControlsView(
        isAskViewPresented: .constant(false),
        selectedItem: .constant(nil),
        camera: CameraService(),
        analysisService: ImageAnalysisService(vlmService: VLMService()))
}

struct LoadingImageView: View {
    var body: some View {
        VStack {
            Spacer()

            ProgressView("Analyzing Image...")
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(10)
            Spacer()
        }
    }
}
