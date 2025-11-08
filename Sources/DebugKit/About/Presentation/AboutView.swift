//
//  AboutView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Version", value: PackageInformation.version)
                LabeledContent("Author", value: PackageInformation.author)
                LabeledContent("Email") {
                    Link(PackageInformation.authorEmail, destination: URL(string: "mailto:\(PackageInformation.authorEmail)")!)
                }
                Link(destination: PackageInformation.packageRepositoryURL) {
                    Label("View Source Code on Github", systemImage: "swift")
                }
                Link(destination: PackageInformation.githubProfileURL) {
                    Label("Developer Portfolio", systemImage: "person.crop.circle")
                }
            } header: {
                Label("Package Information", systemImage: "info.square")
            }
            
            CreditsSectionView()
        }
        .navigationTitle("About")
    }
}

