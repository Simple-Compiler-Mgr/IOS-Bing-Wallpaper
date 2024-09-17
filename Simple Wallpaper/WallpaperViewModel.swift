import SwiftUI

@MainActor
class WallpaperViewModel: ObservableObject {
    @Published var wallpapers: [Wallpaper] = []
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var isAutoUpdateEnabled = false {
        didSet { UserDefaults.standard.set(isAutoUpdateEnabled, forKey: "isAutoUpdateEnabled") }
    }
    @Published var isDarkMode = false {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            updateAppearance()
        }
    }
    @Published var selectedWallpaper: Wallpaper?
    @Published var favoriteWallpapers: Set<UUID> = Set()

    private let bingAPI = BingAPI()
    private let imageSaver = ImageSaver()
    private var timer: Timer?
    
    init() {
        loadSavedSettings()
        Task {
            await fetchWallpapers()
        }
    }
    
    private func loadSavedSettings() {
        isAutoUpdateEnabled = UserDefaults.standard.bool(forKey: "isAutoUpdateEnabled")
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let savedFavorites = UserDefaults.standard.data(forKey: "FavoriteWallpapers"),
           let decodedFavorites = try? JSONDecoder().decode(Set<UUID>.self, from: savedFavorites) {
            favoriteWallpapers = decodedFavorites
        }
        updateAppearance()
    }
    
    func fetchWallpapers() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            wallpapers = try await bingAPI.fetchWallpapers(count: 7)
        } catch {
            print("Failed to fetch wallpapers: \(error)")
        }
        isLoading = false
    }
    
    func saveAndSetWallpaper(_ wallpaper: Wallpaper) {
        guard let image = wallpaper.image else { return }
        imageSaver.saveImage(image)
        showingAlert = true
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func startAutoUpdate() {
        stopAutoUpdate()
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchWallpapers()
            }
        }
    }
    
    func stopAutoUpdate() {
        timer?.invalidate()
        timer = nil
    }
    
    func toggleFavorite(_ wallpaper: Wallpaper) {
        if favoriteWallpapers.contains(wallpaper.id) {
            favoriteWallpapers.remove(wallpaper.id)
        } else {
            favoriteWallpapers.insert(wallpaper.id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ wallpaper: Wallpaper) -> Bool {
        favoriteWallpapers.contains(wallpaper.id)
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteWallpapers) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteWallpapers")
        }
    }
    
    private func updateAppearance() {
        if #available(iOS 15.0, *) {
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.first?.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
                }
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
            }
        }
    }
    
    func shareItems(for wallpaper: Wallpaper) -> [Any]? {
        guard let image = wallpaper.image else { return nil }
        return [image, wallpaper.title, wallpaper.copyright]
    }
}

struct Wallpaper: Identifiable {
    let id = UUID()
    let date: String
    let title: String
    let copyright: String
    let urlString: String
    var image: UIImage?
}