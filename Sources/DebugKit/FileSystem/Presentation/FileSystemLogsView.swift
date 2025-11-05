//
//  FileSystemLogsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import SwiftUI

struct FileSystemLogsView: View {
    @Environment(FileSystemLogManager.self) private var manager
    
    @State private var isShowingPersistedLogs = false
    
    var body: some View {
        VStack(spacing: .zero) {
            if isShowingPersistedLogs,
               !manager.persistedLogs.isEmpty {
                List(manager.persistedLogs) { log in
                    FileSystemLogSectionView(log: log, isPersisted: Binding { true } set: { _ in manager.removePersistedLog(log) })
                }
            } else if manager.logs.isEmpty {
                ContentUnavailableView("No Logs", systemImage: "folder.badge.questionmark")
            } else {
                List(manager.logs) { log in
                    let isPersistedBinding = Binding<Bool> {
                        manager.persistedLogs.contains(where: { $0.id == log.id })
                    } set: { value in
                        if value {
                            manager.persist(log)
                        } else {
                            manager.removePersistedLog(log)
                        }
                    }
                    FileSystemLogSectionView(log: log, isPersisted: isPersistedBinding)
                }
            }
        }
        .animation(.smooth, value: manager.logs)
        .toolbar {
            if !manager.persistedLogs.isEmpty {
                Toggle("Persisted Logs", systemImage: "bookmark.fill", isOn: $isShowingPersistedLogs.animation(.smooth))
            }
            Button("Clear", systemImage: "clear", role: .destructive) {
                manager.logs.removeAll()
            }
        }
        .navigationTitle("File System Logs")
    }
}

private struct FileSystemLogSectionView: View {
    var log: FileSystemLog
    @Binding var isPersisted: Bool
    
    var body: some View {
        Section {
            LabeledContent("Root Directory") {
                HStack(spacing: 4) {
                    Text(log.rootDirectory.title)
                    Image(systemName: log.rootDirectory.systemImage)
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
            }
            LabeledContent("Timestamp", value: log.timestamp, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))
            ForEach(Array(log.difference), id: \.self) { change in
                switch change {
                case .insert(_, let element, let associatedWith):
                    if associatedWith != nil {
                        Label(element.absoluteString, systemImage: "arrow.left.arrow.right")
                            .foregroundStyle(.purple)
                    } else {
                        Label(element.absoluteString, systemImage: "plus")
                            .foregroundStyle(.green)
                    }
                case .remove(_, let element, let associatedWith):
                    if associatedWith != nil {
                        Label(element.relativeString, systemImage: "arrow.left.arrow.right")
                            .foregroundStyle(.purple)
                    } else {
                        Label(element.relativeString, systemImage: "minus")
                            .foregroundStyle(.red)
                    }
                }
            }
        } header: {
            HStack(spacing: 8) {
                Label(log.event.description, systemImage: log.event.systemImage)
                Spacer()
                Toggle("Persisted", systemImage: isPersisted ? "bookmark.fill" : "bookmark", isOn: $isPersisted)
                    .if(UIDevice.current.userInterfaceIdiom == .phone) {
                        $0.labelStyle(.iconOnly)
                    }
                    .toggleStyle(.button)
            }
        }
    }
}
