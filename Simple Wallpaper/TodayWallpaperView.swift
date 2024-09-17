import SwiftUI

struct TodayWallpaperView: View {
    let wallpaper: Wallpaper
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = wallpaper.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
            } else {
                ProgressView()
                    .frame(height: 200)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(wallpaper.title)
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                
                Text(extractCopyrightInfo(from: wallpaper.copyright))
                    .font(.caption)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.5))
            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        }
        .frame(height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}