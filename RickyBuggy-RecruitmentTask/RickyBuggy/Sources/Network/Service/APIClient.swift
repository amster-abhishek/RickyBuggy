//
//  APIService.swift
//  RickyBuggy
//

import Foundation
import Combine

final class APIClient: APIProtocol {
    private let networkManager: NetworkManagerProtocol?
    
    init() {
        self.networkManager = DIContainer.shared.resolve(NetworkManager.self)
    }
    
    func imageDataPublisher(fromURLString urlString: String) -> ImageDataPublisher {
        guard let networkManager = networkManager,
              let url = URL(string: urlString) else { 
            return Empty().eraseToAnyPublisher() 
        }
        
        return networkManager.publisher(fromFullURL: url)
            .mapError { error in APIError.imageDataRequestFailed(error: error) }
            .eraseToAnyPublisher()
    }
    
    func charactersPublisher() -> CharactersPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        let request = NetworkRequest.get(path: "/api/character/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20", timeout: 10.0)
        return networkManager.publisher(request: request)
            .decode(type: [CharacterResponseModel].self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint(error)
                return APIError.charactersRequestFailed(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    func characterDetailPublisher(with id: String) -> CharacterDetailsPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        let request = NetworkRequest.get(path: "/api/character/\(id)", timeout: 10.0)
        return networkManager.publisher(request: request)
            .decode(type: CharacterResponseModel.self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint(error)
                return APIError.characterDetailRequestFailed(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    func locationPublisher(with id: String) -> LocationPublisher {
        guard let networkManager = networkManager else { return Empty().eraseToAnyPublisher() }

        let request = NetworkRequest.get(path: "/api/location/\(id)", timeout: 10.0)
        return networkManager.publisher(request: request)
            .decode(type: LocationDetailsResponseModel.self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint(error)
                return APIError.locationRequestFailed(error: error)
            }
            .eraseToAnyPublisher()
    }
}
