//
//  OnboardingView.swift
//  MpesaTracker
//
//  Created by Ian Kiprotich on 01/06/2026.
//

import SwiftUI
import SwiftData
import UserNotifications
import UniformTypeIdentifiers

// MARK: - OnboardingView

struct OnboardingView: View {
    @AppStorage(OnboardingConstants.hasCompletedOnboardingKey)
    private var hasCompletedOnboarding = false

    @Environment(\.modelContext) private var modelContext

    @State private var currentPage = 0
    @State private var selectedCategories: Set<Category> = []
    @State private var fileImporterPresented = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: pageBinding) {
                    OnboardingScreen1Welcome().tag(0)
                    OnboardingScreen2HowItWorks().tag(1)
                    OnboardingScreen3Permissions().tag(2)
                    OnboardingScreen4Categories(selectedCategories: $selectedCategories).tag(3)
                    OnboardingScreen5Import().tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomControls
        }
        .fileImporter(isPresented: $fileImporterPresented, allowedContentTypes: [UTType.pdf]) { result in
            handleImport(result)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            if currentPage > 0 {
                Button {
                    withAnimation(.spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)) {
                        currentPage -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(.label))
                }
                .accessibilityLabel("Back")
            }

            Spacer()

            if currentPage < 3 {
                Button("Skip") {
                    withAnimation(.spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)) {
                        currentPage = OnboardingConstants.skipTargetPage
                    }
                }
                .font(OFont.body)
                .foregroundStyle(Color(.secondaryLabel))
                .accessibilityLabel("Skip to import screen")
            }
        }
        .frame(height: OnboardingConstants.topBarHeight)
        .padding(.horizontal, OSpacing.xl)
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        VStack(spacing: OSpacing.md) {
            OnboardingPageIndicator(pageCount: OnboardingConstants.pageCount, currentPage: currentPage)

            OnboardingPrimaryButton(
                title: ctaTitle,
                isEnabled: ctaEnabled,
                action: handleCTA
            )

            secondaryLinkArea
        }
        .padding(.top, OSpacing.sm)
        .padding(.bottom, OSpacing.xl)
        .background(Color(.systemBackground))
    }

    private var secondaryLinkArea: some View {
        Button(secondaryTitle ?? " ") { handleSecondary() }
            .font(OFont.body)
            .foregroundStyle(Color(.secondaryLabel))
            .frame(minHeight: 44)
            .opacity(secondaryTitle == nil ? 0 : 1)
            .disabled(secondaryTitle == nil)
            .accessibilityHidden(secondaryTitle == nil)
    }

    // MARK: - Computed state

    private var ctaTitle: String {
        switch currentPage {
        case 0: return "Get started"
        case 1: return "See how it works"
        case 2: return "Enable notifications"
        case 3: return "These look right"
        case 4: return "Import my statement"
        default: return "Continue"
        }
    }

    private var ctaEnabled: Bool {
        currentPage == OnboardingConstants.categoryPage ? !selectedCategories.isEmpty : true
    }

    private var secondaryTitle: String? {
        switch currentPage {
        case 2: return "Not now"
        case 4: return "I'll do this later"
        default: return nil
        }
    }

    // MARK: - Navigation binding

    private var pageBinding: Binding<Int> {
        Binding(
            get: { currentPage },
            set: { newPage in
                let blockForward = newPage > currentPage
                    && currentPage == OnboardingConstants.categoryPage
                    && selectedCategories.isEmpty
                if blockForward { return }
                withAnimation(.spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)) {
                    currentPage = newPage
                }
            }
        )
    }

    // MARK: - Actions

    private func handleCTA() {
        switch currentPage {
        case 0, 1: advance()
        case 2:    requestNotifications()
        case 3:    persistCategories(); advance()
        case 4:    fileImporterPresented = true
        default:   break
        }
    }

    private func handleSecondary() {
        switch currentPage {
        case 2: advance()
        case 4: complete()
        default: break
        }
    }

    private func advance() {
        withAnimation(.spring(response: OnboardingConstants.springResponse, dampingFraction: OnboardingConstants.springDamping)) {
            currentPage = min(currentPage + 1, OnboardingConstants.pageCount - 1)
        }
    }

    private func complete() {
        hasCompletedOnboarding = true
    }

    private func requestNotifications() {
        Task {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            advance()
        }
    }

    private func persistCategories() {
        guard let data = try? JSONEncoder().encode(Array(selectedCategories)) else { return }
        UserDefaults.standard.set(data, forKey: OnboardingConstants.preferredCategoriesKey)
    }

    private func handleImport(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        _ = try? ImportService().importStatement(from: url, into: modelContext)
        complete()
    }
}
