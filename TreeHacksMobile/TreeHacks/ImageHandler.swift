import ARKit
import RealityKit

class ImageRecognitionHandler: NSObject, ObservableObject, ARSessionDelegate {
    @Published var isImageRecognized: Bool = false

    func setupARSession(with arView: ARView) {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages

        // Add other AR features here
        configuration.planeDetection = [.horizontal, .vertical] // Example: Enable plane detection

        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = self
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor.isTracked {
                self.isImageRecognized = true
                break
            }
        }
    }
}
