//
//  CharactersListView.swift
//  RickyBuggy
//

import SwiftUI

struct CharactersListView: View {
    @Binding private var characters: [CharacterResponseModel]
    @Binding private var sortMethod: SortMethod
    
    init(characters: Binding<[CharacterResponseModel]>, sortMethod: Binding<SortMethod>) {
        _characters = characters
        _sortMethod = sortMethod
    }
    
    private var sortedCharacters: [CharacterResponseModel] {
        switch sortMethod {
        case .name:
            return characters.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .episodesCount:
            return characters.sorted { $0.episode.count > $1.episode.count }
        }
    }
    
    var body: some View {
        List(sortedCharacters) { character in
            let destinationViewModel = CharacterDetailViewModel(characterId: character.id, name: character.name)
            let destination = CharacterDetailView(viewModel: destinationViewModel)

            NavigationLink(destination: destination) {
                let viewModel = CharactersListItemViewModel(character: character)

                CharactersListItemView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Preview

struct CharactersListView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersListView(characters: .constant([.dummy]), sortMethod: .constant(.name))
    }
}
