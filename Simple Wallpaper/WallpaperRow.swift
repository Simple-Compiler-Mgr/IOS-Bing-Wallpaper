import SwiftUI

struct WallpaperRow: View {
    let wallpaper: Wallpaper
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if let image = wallpaper.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                } else {
                    ProgressView()
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(wallpaper.title)
                        .font(.headline)
                        .fontWeight(.light)
                    Text(extractCopyrightInfo(from: wallpaper.copyright))
                        .font(.caption)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 15)
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .frame(height: 100)
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
    }
}