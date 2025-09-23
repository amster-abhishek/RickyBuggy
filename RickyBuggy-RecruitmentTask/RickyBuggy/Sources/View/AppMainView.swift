//
//  AppMainView.swift
//  RickyBuggy
//

import SwiftUI

struct AppMainView: View {
    // FIXME: 13 - fix issue with re-invoking network request on tapping show list/hide list
    @ObservedObject var viewModel: AppMainViewModel = AppMainViewModel()
    
    var body: some View {
        NavigationView {
            characterListView
                .navigationTitle(Text("Characters"))
                .navigationBarTitleDisplayMode(.automatic)
                // FIX ME: 7 - Fix issue with glitching toolbar on entering details view
                // Fixed fix 7: issue due to multiple navigation
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        sortButton
                    }
                }
        }
        .confirmationDialog("Sort method", isPresented: $viewModel.showsSortActionSheet) {
            Button("Episodes Count") {
                viewModel.setSortMethod(.episodesCount)
                viewModel.dismissSortActionSheet()
            }
            Button("Name") {
                viewModel.setSortMethod(.name)
                viewModel.dismissSortActionSheet()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissSortActionSheet()
            }
        } message: {
            Text("Choose sorting method")
        }
    }
}

// MARK: - View

private extension AppMainView {
    @ViewBuilder var characterListView: some View {
        if viewModel.characters.isEmpty == false {
            CharactersListView(characters: $viewModel.characters, sortMethod: $viewModel.sortMethod)
        } else if viewModel.characterErrors.isEmpty == false {
            FetchRetryView(errors: viewModel.characterErrors, onRetry: {
                viewModel.requestData()
            })
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }

    var sortButton: some View {
        Button(action: viewModel.setShowsSortActionSheet) {
            Text("Choose Sorting")
        }
    }
    
    // FIX ME: 8 - Fix action sheet only appearing once, in other words - after it gets opened and closed, it cannot be opened again
    // Fixed fix 8 - Replaced deprecated ActionSheet with confirmationDialog
}

// MARK: - Preview

struct AppMainView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
    }
}
