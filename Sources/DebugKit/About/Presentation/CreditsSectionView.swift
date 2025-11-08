//
//  CreditsSectionView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import SwiftUI

struct CreditsSectionView: View {
    var body: some View {
        Section {
            VStack(spacing: 6) {
                Text("Made with ♥︎")
                    .font(.caption.weight(.semibold))
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("© 2025")
                    Link("@nozhana", destination: PackageInformation.githubProfileURL)
                        .bold()
                        .underline()
                }
                .font(.caption2.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }
}
