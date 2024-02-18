import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Combine
import AVFoundation
import AlertToast

struct ARExperienceView: View {
    @State private var modelEntities: [ModelEntity] = []
    @State private var selectedModelName: String? = "tree.usdz"
    @State private var arCoordinator: ARContainerView.Coordinator?
    @State private var isRecording: Bool = false
    @State private var transcribedText: String = ""
    @State private var fillIcon: Bool = false
    
    @State private var showLabelTick: Bool = false
    @State private var showLabelToast: Bool = false
    @State private var isFirstTimeRecording: Bool = true
    
    @State private var instructions: [InstructionStep] = []
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        NavigationView {
            ZStack {
                ARContainerView(selectedModelName: $selectedModelName, modelEntities: $modelEntities)

                VStack {
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            ExpandableEvent(instructions: $instructions)
                            Image(systemName: fillIcon ? "square.stack.3d.up.fill" : "square.stack.3d.up") // Change icon based on fillIcon
                                .padding(.top, 12)
                        }
                        .padding(.top, 80)
                    }
    
                    Spacer()
                    
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.clear)
                            .frame(width: 300, height: 110)
                            .background(.thinMaterial)
                            .cornerRadius(14)
                            .overlay(
                                VStack(alignment: .leading) {
                                    Text("Voice Prompt").bold()
                                        .padding([.leading, .top], 12)
                                    
                                    HStack {
                                        Text(speechRecognizer.transcript)
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing, .bottom], 12)
                                    .padding(.top, 1)
                                    
                                    Spacer()
                                }
                            )
                        
                        Button {
                            if isRecording {
                                speechRecognizer.stopTranscribing()
                                
                                postPromptAndGetInstructions(prompt: speechRecognizer.transcript, label: "Test") { newInstructions, modelName in
                                    self.instructions = newInstructions
                                    print("Updated instructions: \(self.instructions)")
                                    if let modelName = modelName {
                                        self.selectedModelName = modelName
                                    }
                                }
                                
                            } else {
                                if isFirstTimeRecording {
                                    let delay = Double.random(in: 2...4)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                        self.showLabelTick = true
                                        showLabelToast.toggle()
                                    }
                                    isFirstTimeRecording = false
                                }
                                speechRecognizer.startTranscribing()
                            }
                            isRecording.toggle()
                        } label: {
                            ZStack {
                                Color.clear.frame(width: 64, height: 64)
                                Image(systemName: "mic.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: isRecording ? 36 : 32, height: isRecording ? 36 : 32)
                                    .foregroundColor(isRecording ? .red.opacity(0.7) : .white)
                                    .animation(.easeInOut(duration: 0.3), value: isRecording)
                            }
                        }
                        .background(.thinMaterial)
                        .cornerRadius(50)
                        .padding(.leading, 4)
                    }
                    .offset(y: -40)
                }
                .padding([.leading, .trailing], 16)
            }
            .onChange(of: speechRecognizer.transcript) { newValue in
                transcribedText = newValue
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            )
            .edgesIgnoringSafeArea([.top, .bottom])
            .foregroundColor(.white)
            .toast(isPresenting: $showLabelToast){
                AlertToast(type: .regular, title: "Object Identified")
            }
        }
    }
    
    func postPromptAndGetInstructions(prompt: String, label: String, completion: @escaping ([InstructionStep], String?) -> Void) {
        guard let url = URL(string: "http://10.32.78.187:3000/chat") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["prompt": prompt, "label": label]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request error: \(error)")
                return
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode([String: String].self, from: data)
                    
                    // Extract steps
                    let steps = response.filter { key, _ in
                        return ["1", "2", "3"].contains(key)
                    }.sorted(by: { $0.key < $1.key })
                    .map { InstructionStep(step: $0.key, description: $0.value) }
                    
                    // Extract model name and convert to filename
                    let modelName = response["label"].flatMap { "\($0).usdz" }

                } catch {
                    print("Failed to decode response: \(error)")
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                DispatchQueue.main.async {
                    self.fillIcon = true
                }
            }
        }.resume()
    }
}

struct ARContainerView: UIViewRepresentable {
    @Binding var selectedModelName: String?
    @Binding var modelEntities: [ModelEntity]

    func makeUIView(context: Context) -> ARView {
        let view = ARView()

        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        view.session.delegate = context.coordinator

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = view.session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        context.coordinator.view = view

        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )

        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedModelName: $selectedModelName)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var selectedModelName: Binding<String?>
        var focusEntity: FocusEntity?
        var addedAnchors: [AnchorEntity] = []
        
        init(selectedModelName: Binding<String?>) {
            self.selectedModelName = selectedModelName
            
            super.init()
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else { return }

            if self.focusEntity == nil {
                self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
            } else {
            }
        }
        
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            guard let view = self.view, let focusEntity = self.focusEntity else { return }

            if let modelName = selectedModelName.wrappedValue {
                let anchor = AnchorEntity()
                view.scene.anchors.append(anchor)

                let modelEntity = try! ModelEntity.loadModel(named: modelName)
                modelEntity.scale = [0.2, 0.2, 0.2]
                modelEntity.position = focusEntity.position
                modelEntity.generateCollisionShapes(recursive: true)
                view.installGestures([.all], for: modelEntity)

                anchor.addChild(modelEntity)

                addedAnchors.append(anchor)
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct ARExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        ARExperienceView()
    }
}

struct Clothing: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var thumbnail: String
    var model: String
}

var clothes: [Clothing] = [
    Clothing(name: "Tree", thumbnail: "man", model: "tree.usdz")
]
