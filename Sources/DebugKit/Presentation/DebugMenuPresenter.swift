//
//  DebugMenuPresenter.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

final class DebugMenuPresenter: @unchecked Sendable {
#if os(iOS)
    var shakeMode: DebugMenuView.ShakeMode = .debugMenu {
        didSet {
            setupShakeObservation()
        }
    }
#endif
    
    var presentationMode: DebugMenuView.PresentationMode = .flip
    
    var content: DebugMenuView.Content = { _ in EmptyView() }
    
    private var presentCancellables: Set<AnyCancellable> = []
#if os(iOS)
    private var shakeCancellable: AnyCancellable?
#endif
    
    private var isPresented = false
#if os(iOS)
    private var presentedVC: UIViewController?
#elseif os(macOS)
    private var presentedVC: NSViewController?
#endif
    
    @MainActor
    static let shared = DebugMenuPresenter()
    private init() {
        setupBindings()
    }
    
    @MainActor
    func dismiss() {
        guard isPresented else { return }
        presentedVC?.dismiss(animated: true) { [weak self] in
            self?.presentedVC = nil
            self?.isPresented = false
        }
    }
    
    @MainActor
    private func present(_ content: some View, fullScreen: Bool = true) {
        guard !isPresented else { return }
#if os(iOS)
        var topVc = UIApplication.shared.keyWindow?.rootViewController
        while topVc?.presentedViewController != nil {
            topVc = topVc?.presentedViewController
        }
        let vc = UIHostingController(rootView: content)
        vc.modalPresentationStyle = fullScreen ? .fullScreen : .automatic
        if presentationMode == .flip {
            vc.modalTransitionStyle = fullScreen ? .flipHorizontal : .coverVertical
        }
        topVc?.present(vc, animated: true) {
            self.isPresented = true
        }
        self.presentedVC = vc
#elseif os(macOS)
        var topVc = NSApplication.shared.keyWindow?.contentViewController
        while topVc?.presentedViewControllers?.first != nil {
            topVc = topVc?.presentedViewControllers?.first
        }
        let vc = NSHostingController(rootView: content())
        topVc?.presentAsSheet(vc)
        self.isPresented = true
        self.presentedVC = vc
#endif
    }
    
    private func presentDebugMenu() {
        DispatchQueue.main.async {
            self.present(DebugMenuView())
        }
    }
    
    private func presentNetworkLogs() {
        DispatchQueue.main.async {
            let logsView = NavigationStack {
                NetworkLogsView()
            }
            .onDisappear {
                self.presentedVC = nil
                self.isPresented = false
            }
            .environment(NetworkLogManager.shared)
            
            self.present(logsView, fullScreen: false)
        }
    }
    
    private func presentNetworkEvents() {
        DispatchQueue.main.async {
            let eventsView = NavigationStack {
                NetworkEventsView()
            }
            .onDisappear {
                self.presentedVC = nil
                self.isPresented = false
            }
            .environment(NetworkLogManager.shared)
            
            self.present(eventsView, fullScreen: false)
        }
    }
    
    private func presentFileSystemLogs() {
        DispatchQueue.main.async {
            let logsView = NavigationStack {
                FileSystemLogsView()
            }
            .onDisappear {
                self.presentedVC = nil
                self.isPresented = false
            }
            .environment(FileSystemLogManager.shared)
            
            self.present(logsView, fullScreen: false)
        }
    }
    
    private func presentDatabaseLogs() {
        DispatchQueue.main.async {
            let logsView = NavigationStack {
                DatabaseLogsView()
            }
            .onDisappear {
                self.presentedVC = nil
                self.isPresented = false
            }
            .environment(DatabaseLogManager.shared)
            
            self.present(logsView, fullScreen: false)
        }
    }
    
#if os(iOS)
    private func setupShakeObservation() {
        shakeCancellable = shakeMode == .disabled ? nil : NotificationCenter.default.publisher(for: .deviceDidShake)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                switch shakeMode {
                case .debugMenu:
                    presentDebugMenu()
                case .networkLogs:
                    presentNetworkLogs()
                case .networkEvents:
                    presentNetworkEvents()
                case .fileSystemLogs:
                    presentFileSystemLogs()
                case .databaseLogs:
                    presentDatabaseLogs()
                default:
                    break
                }
            }
    }
#endif
    
    private func setupBindings() {
#if os(iOS)
        setupShakeObservation()
#endif
        
        NotificationCenter.default.publisher(for: .presentDebugMenu)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentDebugMenu()
            }
            .store(in: &presentCancellables)
        
        NotificationCenter.default.publisher(for: .presentNetworkLogs)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentNetworkLogs()
            }
            .store(in: &presentCancellables)
        
        NotificationCenter.default.publisher(for: .presentNetworkEvents)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentNetworkEvents()
            }
            .store(in: &presentCancellables)
        
        NotificationCenter.default.publisher(for: .presentFileSystemLogs)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentFileSystemLogs()
            }
            .store(in: &presentCancellables)
        
        NotificationCenter.default.publisher(for: .presentDatabaseLogs)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.presentDatabaseLogs()
            }
            .store(in: &presentCancellables)
    }
}
