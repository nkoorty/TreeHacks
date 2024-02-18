import SwiftUI

struct ExpandableEvent: View {
    @Binding var instructions: [InstructionStep]
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        if isExpanded {
                            Text("Instructions")
                                .font(.title2).bold()
                            
                            Spacer()
                                .frame(width: 320)
                        }
                        Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(14)
                    }
                }

                if isExpanded {
                    ForEach(instructions) { step in
                        HStack {
                            Image(systemName: "\(step.step).circle")
                            Text(step.description)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(14)
            .padding(.top, 60)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


//#Preview {
//    ExpandableEvent()
//}

struct InstructionStep: Identifiable {
    let id = UUID()
    var step: String
    var description: String
}

func loadInstructions(from data: Data) -> [InstructionStep] {
    guard let decodedInstructions = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
        return []
    }
    
    // Filter out unwanted keys and sort
    let filteredInstructions = decodedInstructions
        .filter { ["1", "2", "3"].contains($0.key) }
        .sorted(by: { $0.key < $1.key })
    
    // Convert to InstructionStep array
    return filteredInstructions.map { InstructionStep(step: $0.key, description: $0.value) }
}
