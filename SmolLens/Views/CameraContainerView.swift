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
        ZStack(alignment: .bottom) {
            CameraView(camera: camera)
                .ignoresSafeArea()

            VStack {
                if isAskViewPresented {
                    AskView(
                        isAskViewPresented: $isAskViewPresented,
                        questionText: $questionText,
                        analysisService: analysisService,
                        camera: camera
                    )
                    .padding(.bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    BottomControlsView(
                        isAskViewPresented: $isAskViewPresented,
                        selectedItem: $selectedItem,
                        camera: camera,
                        analysisService: analysisService
                    )
                    .padding(.bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: isAskViewPresented)

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
        .onChange(
            of: selectedItem,
            { oldValue, newValue in
                Task {
                    logger.info("Processing picked photo")
                    if let data = try? await newValue?.loadTransferable(
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
            })
    }
}

struct AskView: View {
    @Binding var isAskViewPresented: Bool
    @Binding var questionText: String
    let analysisService: ImageAnalysisService
    let camera: CameraService

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "camera.aperture")
                    .font(.title2)
                    .foregroundStyle(.gray)
                    .accessibilityHidden(true)

                TextField("Ask about details...", text: $questionText)
                    .foregroundStyle(.primary)

                Button(action: {
                    camera.capturePhoto {
                        if let image = camera.capturedImage {
                            analysisService.analyzeImage(
                                image, prompt: questionText)
                        }
                        isAskViewPresented = false
                        camera.reset()
                        questionText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Send")
                }
                .disabled(questionText.isEmpty)

                Button(action: {
                    isAskViewPresented = false
                    questionText = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Cancel")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.black
            .ignoresSafeArea()

        AskView(
            isAskViewPresented: .constant(true),
            questionText: .constant(""),
            analysisService: ImageAnalysisService(vlmService: VLMService()),
            camera: CameraService())
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
                .background(.regularMaterial)
                .clipShape(Circle())
                .accessibilityLabel("Ask a question")
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
                Spacer()

                AskButton(isAskViewPresented: $isAskViewPresented)

                Spacer()

                CameraControlsView(isCaptured: camera.isCaptured, onCapture: {
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
                            camera.reset()
                        }
                    }
                })

                Spacer()

                LibraryButton(selectedItem: $selectedItem)

                Spacer()

            }
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
                .background(.regularMaterial)
                .cornerRadius(10)
            Spacer()
        }
    }
}
