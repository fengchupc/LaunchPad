//
//  AppGridView.swift
//  LaunchPad
//
//  Created by Chu Feng on 13/6/2025.
//

import SwiftUI
import Combine
import CoreServices

struct AppGridView: View {
    @Binding var apps: [AppModel]
    @Binding var searchText: String
    @State private var draggingItem: AppModel? = nil
    @State private var currentPage: Int = 0
    @State private var expandedFolder: AppModel? = nil // 当前展开的文件夹
    @State private var isDragging = false
    @State private var dragPosition: CGPoint = .zero
    @State private var dragOverItem: AppModel? = nil
    @State private var dragTimer: Timer? = nil

    let columns = [
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80),
        GridItem(.flexible(), spacing: 80)
    ]
    private let itemsPerPage = 35 // 每页显示 35 个应用

    var filteredApps: [AppModel] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var paginatedApps: [[AppModel]] {
        stride(from: 0, to: filteredApps.count, by: itemsPerPage).map {
            Array(filteredApps[$0..<min($0 + itemsPerPage, filteredApps.count)])
        }
    }

    var body: some View {
        VStack {
            if let folder = expandedFolder {
                // 显示展开的文件夹内容
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(folder.children ?? []) { app in
                            AppIconView(app: app, draggingItem: $draggingItem, apps: $apps)
                        }
                    }
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                NSApplication.shared.hide(nil)
                            }
                    )
                }
                Button("Close Folder") {
                    expandedFolder = nil
                }
                .padding()
            } else if !paginatedApps.isEmpty {
                TabView(selection: $currentPage) {
                    ForEach(0..<paginatedApps.count, id: \.self) { pageIndex in
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(paginatedApps[pageIndex]) { app in
                                    if app.isFolder {
                                        FolderIconView(app: app, expandedFolder: $expandedFolder)
                                            .onDrop(of: [.text], delegate: DropViewDelegate(item: app, apps: $apps, draggingItem: $draggingItem, dragTimer: $dragTimer, isDragging: $isDragging))
                                    } else {
                                        AppIconView(app: app, draggingItem: $draggingItem, apps: $apps)
                                    }
                                }
                            }
                            .padding()
                        }
                        .tag(pageIndex) // 确保 tag 值与 pageIndex 匹配
                    }
                }
                .onChange(of: dragOverItem) { oldValue, newValue in
                    // 如果拖动超过一定时间，创建文件夹
                    if let item = newValue {
                        dragTimer?.invalidate()
                        dragTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                            if let draggingItem = draggingItem {
                                createFolderFromItems(item1: item, item2: draggingItem)
                            }
                        }
                    } else {
                        dragTimer?.invalidate()
                        dragTimer = nil
                    }
                }
                .gesture(DragGesture(minimumDistance: 10).onEnded { value in
                    if value.translation.width < 0 && currentPage < paginatedApps.count - 1 {
                        currentPage += 1 // 向左拖动，切换到下一页
                    } else if value.translation.width > 0 && currentPage > 0 {
                        currentPage -= 1 // 向右拖动，切换到上一页
                    }
                }, including: .all) // 确保手势优先级覆盖所有子视图
                .onAppear {
                    print("TabView appeared with currentPage: \(currentPage)") // 添加调试日志
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        if event.keyCode == 123 && currentPage > 0 { // 左箭头
                            currentPage -= 1
                        } else if event.keyCode == 124 && currentPage < paginatedApps.count - 1 { // 右箭头
                            currentPage += 1
                        }
                        return event
                    }
                }
                // 调整分页指示器位置
                HStack {
                    ForEach(0..<paginatedApps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray)
                            .frame(width: 10, height: 10)
                            .onTapGesture {
                                currentPage = index
                            }
                    }
                }
                .padding(.top, 20) // 向上移动分页指示器
            } else {
                Text("No apps found")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func createFolderFromItems(item1: AppModel, item2: AppModel) {
        guard let index1 = apps.firstIndex(where: { $0.id == item1.id }),
              let index2 = apps.firstIndex(where: { $0.id == item2.id }) else {
            return
        }
        
        let folderName = "Folder"
        let folder = createFolder(name: folderName, apps: [item1, item2])
        
        // 移除原始应用
        apps.remove(at: max(index1, index2))
        apps.remove(at: min(index1, index2))
        
        // 添加新文件夹
        apps.insert(folder, at: min(index1, index2))
        
        // 重置拖拽状态
        draggingItem = nil
        dragOverItem = nil
        dragTimer?.invalidate()
        dragTimer = nil
        isDragging = false
    }
}

struct AppIconView: View {
    let app: AppModel
    @Binding var draggingItem: AppModel?
    @Binding var apps: [AppModel]
    @State private var isDragging = false
    @State private var dragTimer: Timer? = nil
    
    var body: some View {
        Button(action: {
            print("Attempting to open app: \(app.name) with URL: \(app.url)")
            
            // 使用 NSWorkspace 打开应用（优先使用）
            DispatchQueue.main.async {
                // 先打开应用
                if NSWorkspace.shared.open(app.url) {
                    // 成功打开后再隐藏启动器
                    DispatchQueue.main.async {
                        NSApplication.shared.hide(nil)
                    }
                    print("Successfully opened app via NSWorkspace: \(app.name)")
                } else {
                    // 如果 NSWorkspace 失败，尝试使用 shell 命令
                    let process = Process()
                    process.launchPath = "/usr/bin/open"
                    process.arguments = [app.url.path]
                    
                    do {
                        try process.run()
                        print("Launched app via shell: \(app.name)")
                    } catch {
                        print("All attempts to open app failed: \(app.name), error: \(error)")
                    }
                }
            }
        }) {
            VStack {
                Image(nsImage: app.icon)                    .resizable()
                    .frame(width: 128, height: 128)
                    .shadow(color: isDragging ? .blue.opacity(0.3) : .clear, radius: 5)
                Text(app.displayName)
                    .font(.caption)
                    .foregroundColor(.white) // 设置文本颜色为白色
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .onDrag {
            draggingItem = app
            isDragging = true
            return NSItemProvider(object: app.name as NSString)
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(
            item: app,
            apps: $apps,
            draggingItem: $draggingItem,
            dragTimer: $dragTimer,
            isDragging: $isDragging
        ))
    }
}

struct FolderIconView: View {
    let app: AppModel
    @Binding var expandedFolder: AppModel?

    var body: some View {
        VStack {
            Image(systemName: "folder.fill")
                .resizable()
                .frame(width: 64, height: 64)
            Text(app.url.localizedDisplayName())
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .onTapGesture {
            expandedFolder = app
        }
    }
}

class DropViewDelegate: DropDelegate {
    var item: AppModel
    @Binding var apps: [AppModel]
    @Binding var draggingItem: AppModel?
    @Binding var dragTimer: Timer?
    @Binding var isDragging: Bool
    
    init(item: AppModel, apps: Binding<[AppModel]>, draggingItem: Binding<AppModel?>, 
         dragTimer: Binding<Timer?>, isDragging: Binding<Bool>) {
        self.item = item
        self._apps = apps
        self._draggingItem = draggingItem
        self._dragTimer = dragTimer
        self._isDragging = isDragging
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggingItem = draggingItem else { return false }
        
        if item.isFolder {
            // 如果目标是文件夹，将拖动的应用程序添加到文件夹中
            var updatedFolder = item
            if updatedFolder.children == nil {
                updatedFolder.children = []
            }
            updatedFolder.children?.append(draggingItem)
            
            // 更新文件夹
            if let index = apps.firstIndex(where: { $0.id == item.id }) {
                apps[index] = updatedFolder
            }
            
            // 移除原始应用
            apps.removeAll { $0.id == draggingItem.id }
        } else if let fromIndex = apps.firstIndex(where: { $0.id == draggingItem.id }),
                  let toIndex = apps.firstIndex(where: { $0.id == item.id }) {
            // 如果目标不是文件夹，执行排序操作
            apps.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        }
        
        // 重置状态
        self.draggingItem = nil
        isDragging = false
        dragTimer?.invalidate()
        dragTimer = nil
        
        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        // 确保拖放的内容有效
        return draggingItem != nil
    }
}

extension URL {
    func localizedApplicationName() -> String {
        let resourceValues = try? resourceValues(forKeys: [.localizedNameKey])
        return resourceValues?.localizedName ?? lastPathComponent
    }
    
    func localizedDisplayName() -> String {
        let resourceKeys: Set<URLResourceKey> = [.localizedNameKey]
        return (try? resourceValues(forKeys: resourceKeys).localizedName) ?? lastPathComponent.replacingOccurrences(of: ".app", with: "")
    }
}

