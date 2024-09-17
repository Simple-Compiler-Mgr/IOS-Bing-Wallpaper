//
//  ContentView.swift
//  Simple Wallpaper
//
//  Created by zuole on 9/16/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WallpaperViewModel()
    @State private var showingSettings = false
    @State private var isListMode = true
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        todayWallpaperView
                        wallpaperList(geometry: geometry)
                    }
                    .padding(.vertical, 1)
                }
            }
            .background(viewModel.isDarkMode ? Color.black : Color(UIColor.systemGroupedBackground))
            .navigationTitle("Simple Wallpapers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingToolbarItems
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarItems
                }
            }
            .refreshable { await viewModel.fetchWallpapers() }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(isAutoUpdateEnabled: $viewModel.isAutoUpdateEnabled, isDarkMode: $viewModel.isDarkMode)
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text("Image Saved"),
                message: Text("The image has been saved to your photo library. Please go to Settings > Wallpaper to set it as your wallpaper."),
                primaryButton: .default(Text("Go to Settings"), action: viewModel.openSettings),
                secondaryButton: .cancel()
            )
        }
        .environmentObject(viewModel)
    }
    
    private var todayWallpaperView: some View {
        Group {
            if let todayWallpaper = viewModel.wallpapers.first {
                NavigationLink(destination: WallpaperDetailView(wallpaper: todayWallpaper)) {
                    TodayWallpaperView(wallpaper: todayWallpaper)
                }
            }
        }
    }
    
    private func wallpaperList(geometry: GeometryProxy) -> some View {
        Group {
            if isListMode {
                ForEach(viewModel.wallpapers.dropFirst()) { wallpaper in
                    NavigationLink(destination: WallpaperDetailView(wallpaper: wallpaper)) {
                        WallpaperRow(wallpaper: wallpaper)
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(viewModel.wallpapers.dropFirst()) { wallpaper in
                        NavigationLink(destination: WallpaperDetailView(wallpaper: wallpaper)) {
                            TileWallpaperView(wallpaper: wallpaper, width: (geometry.size.width - 40) / 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var trailingToolbarItems: some View {
        HStack {
            Button(action: { withAnimation { isListMode.toggle() } }) {
                Image(systemName: isListMode ? "square.grid.2x2" : "list.bullet")
            }
            Button(action: { showingSettings = true }) {
                Image(systemName: "gear")
            }
        }
    }
    
    private var leadingToolbarItems: some View {
        Button(action: { Task { await viewModel.fetchWallpapers() } }) {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    ContentView()
}
