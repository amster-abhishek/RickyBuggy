//
//  CharacterDetailViewModel.swift
//  RickyBuggy
//

import Combine
import Foundation

final class CharacterDetailViewModel: ObservableObject {
    @Published var showsLocationDetailsView = false

    @Published private(set) var data: (characterDetails: CharacterResponseModel, location: LocationDetailsResponseModel)?
    @Published private(set) var CharacterPhotoData: Data?
    @Published private(set) var characterErrors: [APIError] = []

    @Published private(set) var title: String = "-"
    @Published private(set) var popularityName: String = "-"
    @Published private(set) var url: String = "-"
    @Published private(set) var created: String = "-"
    
    @Published private(set) var details: String = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."
    
    private let showsLocationDetailsSubject = CurrentValueSubject<Bool?, Never>(nil)

    private let characterIDSubject = CurrentValueSubject<Int?, Never>(nil)
    private let dataSubject = CurrentValueSubject<(characterDetails: CharacterResponseModel, location: LocationDetailsResponseModel)?, Never>(nil)

    private var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    init(characterId: Int, name: String) {
        self.title = name

        let apiService = DIContainer.shared.resolve(APIClient.self)

        showsLocationDetailsSubject
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.showsLocationDetailsView, on: self)
            .store(in: &cancellables)

        let dataPublisher = dataSubject
            .compactMap { $0 }
            .share()

        let characterDetailsPublisher = dataPublisher
            .map(\.characterDetails)

        dataPublisher
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.characterErrors.append(.characterDetailRequestFailed(error: error))
                }
            }, receiveValue: { [weak self] characterDetail, location in
                self?.data = (characterDetail, location)
            })
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.image)
            .flatMap { imageURLString -> ImageDataPublisher in
                guard let apiService = apiService else {
                    return Empty().eraseToAnyPublisher()
                }
                return apiService.imageDataPublisher(fromURLString: imageURLString)
            }
            .replaceError(with: Data())
            .compactMap { $0 }
            .assign(to: \.CharacterPhotoData, on: self)
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.name)
            .assign(to: \.title, on: self)
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.episode)
            .map(\.count)
            .compactMap(AppearanceFrequency.init(count:))
            .map(\.popularity)
            .assign(to: \.popularityName, on: self)
            .store(in: &cancellables)
        
        characterDetailsPublisher
            .map(\.url)
            .removeDuplicates()
            .assign(to: \.url, on: self)
            .store(in: &cancellables)

        characterDetailsPublisher
            .map(\.created)
            .assign(to: \.created, on: self)
            .store(in: &cancellables)

        characterIDSubject.send(characterId)
    }
    
    // MARK: - Inputs

    func setShowsLocationDetails() {
        showsLocationDetailsSubject.send(true)
    }
    
    func requestData() {
        guard isLoading == false else { return }
        
        data = nil
        characterErrors.removeAll()
        isLoading = true

        if let apiService = DIContainer.shared.resolve(APIClient.self), let characterID = characterIDSubject.value {
            // FIX ME: 11 - FIX so location is fetched based on character location id
            // Fixed fix 11 - First fetch character, then extract location ID and fetch location
            apiService.characterDetailPublisher(with: String(characterID))
                .flatMap { characterDetail -> AnyPublisher<(CharacterResponseModel, LocationDetailsResponseModel), APIError> in
                    // Extract location ID from character's location URL
                    let locationID = self.getLocationID(from: characterDetail.location.url)
                    return apiService.locationPublisher(with: locationID)
                        .map { locationDetails in
                            (characterDetail, locationDetails)
                        }
                        .eraseToAnyPublisher()
                }
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        self?.characterErrors.append(error)
                    case .finished:
                        break
                    }

                    self?.isLoading = false
                }, receiveValue: { [weak self] characterDetail, locationDetails in
                    self?.dataSubject.send((characterDetail, locationDetails))
                })
                .store(in: &cancellables)
        }
    }
    
    private func getLocationID(from locationURL: String) -> String {
        if let url = URL(string: locationURL) {
            let components = url.pathComponents
            if let last = components.last, last != "location" {
                return last
            }
        }
        return "1"
    }
}
