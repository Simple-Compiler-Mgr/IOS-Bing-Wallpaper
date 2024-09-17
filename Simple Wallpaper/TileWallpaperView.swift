import SwiftUI

struct TileWallpaperView: View {
    let wallpaper: Wallpaper
    let width: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = wallpaper.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: 200)
                    .clipped()
                    .cornerRadius(15)
            } else {
                ProgressView()
                    .frame(width: width, height: 200)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(wallpaper.title)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(extractCopyrightInfo(from: wallpaper.copyright))
                    .font(.caption2)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 1, height: 30)
                    .offset(x: -1, y: -15),
                alignment: .bottomTrailing
            )
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 1)
                    .offset(x: -15, y: -1),
                alignment: .bottomTrailing
            )
        }
        .frame(width: width, height: 200)
        .background(colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}