import SwiftUI

struct WallpaperDetailView: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    @State private var showUI = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    let wallpaper: Wallpaper
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let image = wallpaper.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: offset, y: 0)
                        .gesture(dragGesture(geometry: geometry, image: image))
                        .clipped()
                }
                
                if showUI {
                    controlsOverlay
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .gesture(TapGesture().onEnded { _ in
            withAnimation { showUI.toggle() }
        })
        .sheet(isPresented: $showingShareSheet) {
            if let items = viewModel.shareItems(for: wallpaper) {
                ActivityViewController(activityItems: items)
            }
        }
    }
    
    private var controlsOverlay: some View {
        VStack {
            Spacer()
            ZStack {
                wallpaper.image.map { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .blur(radius: 20)
                        .overlay(Color.black.opacity(0.4))
                        .clipped()
                }
                
                VStack(spacing: 10) {
                    Text(wallpaper.title)
                        .font(.headline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                    
                    Text(wallpaper.copyright)
                        .font(.caption)
                        .fontWeight(.ultraLight)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Spacer()
                        Button(action: {
                            viewModel.saveAndSetWallpaper(wallpaper)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save and Set")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        Spacer()
                        Button(action: { viewModel.toggleFavorite(wallpaper) }) {
                            Image(systemName: viewModel.favoriteWallpapers.contains(wallpaper.id) ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.favoriteWallpapers.contains(wallpaper.id) ? .red : .white)
                        }
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(height: 150)
            }
        }
        .transition(.opacity)
    }
    
    private func dragGesture(geometry: GeometryProxy, image: UIImage) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newOffset = self.lastOffset + value.translation.width
                let maxOffset = (image.size.width * (geometry.size.height / image.size.height) - geometry.size.width) / 2
                self.offset = min(max(newOffset, -maxOffset), maxOffset)
            }
            .onEnded { _ in
                self.lastOffset = self.offset
            }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}