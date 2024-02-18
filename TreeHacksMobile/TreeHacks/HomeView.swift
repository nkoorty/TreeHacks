import SwiftUI

struct HomeView: View {
    
    @State private var showArView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        ZStack(alignment: .bottomLeading) {
                            Image("background")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipped()
                                .background(.thinMaterial)
                            VStack {
                                Button {
                                    showArView.toggle()
                                } label: {
                                    Spacer()
                                    HStack {
                                        Text("Enter Aira Experience")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                                                    
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(.thinMaterial)
                                }
                                .fullScreenCover(isPresented: $showArView, content: {
                                    ARExperienceView()
                                })

                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .cornerRadius(20)
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
