//
//  DatabaseLogsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import SwiftData
import SwiftUI

struct DatabaseLogsView: View {
    @Environment(DatabaseLogManager.self) private var manager
    
    var body: some View {
        VStack(spacing: .zero) {
            if manager.logs.isEmpty {
                ContentUnavailableView("No Logs", systemImage: "cylinder.split.1x2")
            } else {
                List(manager.logs) { log in
                    DatabaseLogSectionView(log: log)
                }
            }
        }
        .animation(.smooth, value: manager.logs)
        .toolbar {
            Button("Clear", systemImage: "clear", role: .destructive) {
                manager.logs.removeAll()
            }
        }
        .navigationTitle("Database Logs")
    }
}

#Preview {
    DatabaseLogsView()
}

private struct DatabaseLogSectionView: View {
    var log: DatabaseLog
    
    var body: some View {
        Section {
            LabeledContent("Description", value: log.event.description)
            LabeledContent("Timestamp", value: log.timestamp, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))
            switch log.event {
            case .save(let inserted, let updated, let deleted):
                if !inserted.isEmpty {
                    LabeledContent("Inserted") {
                        Text("+^[\(inserted.count) item](inflect: true)")
                    }
                    ForEach(inserted.sorted()) { id in
                        objectRow(for: id, systemImage: "plus", foregroundStyle: .green)
                    }
                }
                if !updated.isEmpty {
                    LabeledContent("Updated") {
                        Text("^[\(updated.count) item](inflect: true)")
                    }
                    ForEach(updated.sorted()) { id in
                        objectRow(for: id, systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90", foregroundStyle: .blue)
                    }
                }
                if !deleted.isEmpty {
                    LabeledContent("Deleted") {
                        Text("-^[\(deleted.count) item](inflect: true)")
                    }
                    ForEach(deleted.sorted()) { id in
                        objectRow(for: id, systemImage: "minus", foregroundStyle: .red)
                    }
                }
            }
        } header: {
            Label(log.event.title, systemImage: log.event.systemImage)
        }
    }
    
    @ViewBuilder
    private func objectRow(for id: PersistentIdentifier, systemImage: String, foregroundStyle: some ShapeStyle) -> some View {
        if let jsonData = try? JSONEncoder().encode(id),
           let jsonObject = try? JSONDecoder().decode(AnyJSONObject.self, from: jsonData),
           case .object(let implementation) = jsonObject["implementation"] {
            let (entityName, primaryKey): (String, String) = {
                if case .string(let entityName) = implementation["entityName"],
                   case .string(let primaryKey) = implementation["primaryKey"] {
                    return (entityName, primaryKey)
                }
                return ("N/A", "N/A")
            }()
            
            NavigationLink {
                AnyJSONObjectVisualizerView(object: implementation)
                    .navigationTitle("\(entityName) | \(primaryKey)")
            } label: {
                Label {
                    HStack(spacing: 8) {
                        Text(entityName)
                        Divider()
                        Text(primaryKey)
                            .bold()
                    }
                } icon: {
                    Image(systemName: systemImage)
                }
                .foregroundStyle(foregroundStyle)
            }
        } else {
            Label("N/A", systemImage: systemImage)
                .foregroundStyle(foregroundStyle)
        }
    }
}
