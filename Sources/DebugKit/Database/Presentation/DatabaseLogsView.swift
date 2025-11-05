//
//  DatabaseLogsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

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
                }
                if !updated.isEmpty {
                    LabeledContent("Updated") {
                        Text("^[\(updated.count) item](inflect: true)")
                    }
                }
                if !deleted.isEmpty {
                    LabeledContent("Deleted") {
                        Text("-^[\(deleted.count) item](inflect: true)")
                    }
                }
            }
        } header: {
            Label(log.event.title, systemImage: log.event.systemImage)
        }
    }
}
