//
//  CharacterDetailView.swift
//  RickyBuggy
//

import SwiftUI

struct CharacterDetailView: View {
    @ObservedObject private var viewModel: CharacterDetailViewModel
    
    init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.requestData) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
    }
}

private extension CharacterDetailView {
    @ViewBuilder var content: some View {
        if viewModel.data != nil {
            ScrollView {
                VStack(alignment: .leading) {
                    titleSection
                    photoSection
                    detailsSection
                    locationSection
                }
            }
        } else if viewModel.characterErrors.isEmpty == false {
            FetchRetryView(errors: viewModel.characterErrors, onRetry: viewModel.requestData)
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear {
                    viewModel.requestData()
                }
        }
    }
}

// MARK: - Section: Title

private extension CharacterDetailView {
    // FIX ME: 9 - Fix title (character name) so it's displayed on the top, just below navigation bar
    // Fixed fix 9 - Added title section
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Section: Photo

private extension CharacterDetailView {
    // FIX ME: 10 - Fix so image isn't cropped and still looks good (see Morty for example of how broken it is now)
    // Fixed fix 10 - Use proper aspect ratio and content mode to prevent cropping
    var photoSection: some View {
        VStack(alignment: .center, spacing: 8) {
            CharacterPhoto(data: viewModel.CharacterPhotoData)
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: UIScreen.main.bounds.width - 16, minHeight: UIScreen.main.bounds.width / 5)
                .cornerRadius(8)
        }
        .padding()
    }
}



// MARK: - Section: About

private extension CharacterDetailView {
    var detailsSection: some View {
        VStack(alignment: .center, spacing: 8) {
           
            HStack {
                Text("Popularity level:")
                    .font(.headline)
                Text(viewModel.popularityName)
                    .font(.headline)
            }
            
            Spacer()
            
            Text("About")
                .font(.headline)
            
            Text(viewModel.details)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.leading, 4)
        }
        .padding()
    }
}

// MARK: - Section: Location

private extension CharacterDetailView {
    var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Location")
                    .font(.headline)
                
                Spacer()
                
                Button(action: viewModel.setShowsLocationDetails) {
                    // FIX ME: 12 - change to filled share icon using sfsymbols, confirm if functionallity works, fix if needed
                    // Fixed fix 12 - Changed `globe` icon to to `filled share icon`
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }
            
            // Display location name from fetched data
            if let locationName = viewModel.data?.location.name {
                Text(locationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                Text("Loading location...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showsLocationDetailsView) {
            if let locationDetail = viewModel.data?.location {
                VStack(alignment: .leading) {
                    Text(locationDetail.name)
                        .font(.headline)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    Text(locationDetail.created)
                        .font(.headline)
                    
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    List(locationDetail.residents, id: \.self) { resident in
                        HStack(alignment: .top) {
                            Text(resident)
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}
    
// MARK: - Preview
struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailView(viewModel: CharacterDetailViewModel(characterId: 1, name: "Johnny"))
    }
}
