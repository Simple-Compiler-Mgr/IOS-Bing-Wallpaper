import UIKit

class BingAPI {
    func fetchWallpapers(count: Int) async throws -> [Wallpaper] {
        let urlString = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=\(count)&mkt=en-US"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let json = try JSONDecoder().decode(BingResponse.self, from: data)
        
        return try await withThrowingTaskGroup(of: Wallpaper.self) { group in
            var wallpapers: [Wallpaper] = []
            
            for imageInfo in json.images {
                group.addTask {
                    let fullImageUrlString = "https://www.bing.com\(imageInfo.url)"
                    let image = try await self.downloadImage(from: URL(string: fullImageUrlString)!)
                    return Wallpaper(date: imageInfo.startdate,
                                     title: imageInfo.title,
                                     copyright: imageInfo.copyright,
                                     urlString: fullImageUrlString,
                                     image: image)
                }
            }
            
            for try await wallpaper in group {
                wallpapers.append(wallpaper)
            }
            
            return wallpapers.sorted(by: { $0.date > $1.date })
        }
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "Failed to create image from data", code: 0, userInfo: nil)
        }
        return image
    }
}

struct BingResponse: Codable {
    let images: [ImageInfo]
}

struct ImageInfo: Codable {
    let startdate: String
    let url: String
    let title: String
    let copyright: String
}