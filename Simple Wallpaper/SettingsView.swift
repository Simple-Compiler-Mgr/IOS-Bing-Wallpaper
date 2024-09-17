import SwiftUI

struct SettingsView: View {
    @Binding var isAutoUpdateEnabled: Bool
    @Binding var isDarkMode: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("自动更新")) {
                    Toggle("启用自动更新", isOn: $isAutoUpdateEnabled)
                }
                
                Section(header: Text("外观")) {
                    Toggle("深色模式", isOn: $isDarkMode)
                }
                
                Section(header: Text("关于")) {
                    Text("Simple Wallpaper v1.0")
                    Text("© 2024 Simple Compiler")
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}