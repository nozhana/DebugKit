//
//  AnyJSONObjectVisualizerView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

struct AnyJSONObjectVisualizerView: View {
    var object: AnyJSONObject
    
    var body: some View {
        List {
            if object.isEmpty {
                ContentUnavailableView("Empty Object", systemImage: "square.dashed")
            } else {
                ForEach(object.keys.sorted(), id: \.self) { key in
                    if let element = object[key] {
                        AnyJSONVisualizerView(key: key, json: element)
                    }
                }
            }
        }
    }
}

struct AnyJSONArrayVisualizerView: View {
    var array: AnyJSONArray
    
    var body: some View {
        List {
            if array.isEmpty {
                ContentUnavailableView("Empty Array", systemImage: "square.dashed")
            } else {
                ForEach(array.indices, id: \.self) { index in
                    if array.indices.contains(index) {
                        AnyJSONVisualizerView(key: "Item \(index + 1)", json: array[index])
                    }
                }
            }
        }
    }
}

struct AnyJSONVisualizerView: View {
    var key: String
    var json: AnyJSON
    
    @State private var loadImage = false
    @State private var isRequesting = false
    
    var body: some View {
        switch json {
        case .null:
            LabeledContent(key, value: "null")
        case .bool(let bool):
            LabeledContent(key) {
                Label(bool ? "True" : "False",
                      systemImage: bool ? "checkmark" : "xmark")
            }
        case .int(let int):
            LabeledContent(key, value: int, format: .number)
        case .double(let double):
            LabeledContent(key, value: double, format: .number)
        case .date(let date):
            LabeledContent(key, value: date, format: .dateTime.timeZone(.genericLocation).year().month().day().hour().minute().second().secondFraction(.fractional(3)))
        case .string(let string):
            LabeledContent(key, value: string)
                .if(URL(string: string)?.scheme?.starts(with: /https?/) == true) {
                    $0.safeAreaInset(edge: .trailing, spacing: 16) {
                        if let url = URL(string: string), url.scheme != nil {
                            if loadImage {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 64, height: 64)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                let lastComponent = url.lastPathComponent
                                if lastComponent.hasSuffix("png") || lastComponent.hasSuffix("jpg") || lastComponent.hasSuffix("jpeg") || lastComponent.hasSuffix("webp") {
                                    Button("Load Image", systemImage: "arrowshape.down.circle") {
                                        withAnimation(.smooth) {
                                            loadImage = true
                                        }
                                    }
#if os(iOS)
                                    .if(UIDevice.current.userInterfaceIdiom == .phone) {
                                        $0.labelStyle(.iconOnly)
                                    }
#endif
                                } else {
                                    Button("Request URL", systemImage: "tray.and.arrow.down") {
                                        Task {
                                            isRequesting = true
                                            defer { isRequesting = false }
                                            do {
                                                _ = try await URLSession.debug.data(from: url)
                                            } catch {
                                                print("Request failed: \(error.localizedDescription)")
                                                print("Type: \(String(describing: type(of: error)))")
                                                print("Reflection: \(String(reflecting: error))")
                                            }
                                        }
                                    }
#if os(iOS)
                                    .if(UIDevice.current.userInterfaceIdiom == .phone) {
                                        $0.labelStyle(.iconOnly)
                                    }
#endif
                                    .disabled(isRequesting)
                                    .overlay {
                                        if isRequesting {
                                            ProgressView()
                                        }
                                    }
                                    .animation(.smooth, value: isRequesting)
                                }
                            }
                        }
                    }
                }
        case .array(let array):
            NavigationLink {
                AnyJSONArrayVisualizerView(array: array)
                    .navigationTitle(key)
            } label: {
                LabeledContent(key) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Array")
                        Text("^[\(array.count) item](inflect: true)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case .object(let object):
            NavigationLink {
                AnyJSONObjectVisualizerView(object: object)
                    .navigationTitle(key)
            } label: {
                LabeledContent(key) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Object")
                        Text("^[\(object.count) item](inflect: true)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
