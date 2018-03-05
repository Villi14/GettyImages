//
//  SearchPhoto.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/1/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

struct HttpResponse {
    let headers: [AnyHashable: Any]
    let body: [String: Any]
}

enum ErrorResult: Error {
    case network(string: String)
    case parser(string: String)
}

struct URLBuilder {
    private let path: String
    private let params: [String: Any]
    
    init(path: String, params: [String: Any]) {
        self.path = path
        self.params = params
    }
    
    func build() -> URL {
        let urlString = "https://api.gettyimages.com/v3" + path
        return URL(string: urlString + "?" + params.stringFromHttpParameters())!
    }
}

typealias HttpResponseResultCompletion = (Result<HttpResponse, ErrorResult>) -> Void
typealias NewTokenResultCompletion = (Result<(token: String, expiresIn: Int), ErrorResult>) -> Void
typealias TokenResultCompletion = (Result<String, ErrorResult>) -> Void

class SearchPhotoProvider: SearchProvider {
    private let keyApiToken = "keyApiToken"
    private let keyDateExpiresIn = "keyDateExpiresIn"
    // Getty Test: Sandbox
    private let apiKey = "tkjxvsr5xmyrkykzpwu7ypk9"
    private let secret = "nZjHx3dYWyhYmS2me2cJ9cgYrCvmgQyF8AWrQkqP9BvRE"
    private let urlGetTokenString = "https://api.gettyimages.com/oauth2/token"
    lazy private var realmStorag = RealmPhotoEntityPersistentStorage()
    private let defaults = UserDefaults.standard
    
    func onDidLoad() -> [PhotoEntity] {
        return realmStorag.allPhoto()
    }
    
    func onSearch(text: String, completion: @escaping (PhotoEntity?) -> Void) {
        let url = buildSearchUrl(searchText: text)
        fetch(url) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(response):
                print(response.body)
                if let images = response.body["images"] as? [[String: Any]],
                    let image = images.first,
                    let id = image["id"] as? String,
                    let title = image["title"] as? String,
                    let displaySizes = image["display_sizes"] as? [[String: Any]],
                    let firstObject = displaySizes.first,
                    let uriThumb = firstObject["uri"] as? String
                {
                    let photoEntity = PhotoEntity(
                        searchText: text,
                        id: id,
                        date: Date(),
                        title: title,
                        uriThumb: uriThumb,
                        uri: "")
                    strongSelf.realmStorag.addPhoto(photo: photoEntity)
                    completion(photoEntity)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func onDownload(id: String, completion: @escaping (String?) -> Void ) {
        getToken(completion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(apiToken):
                let url = strongSelf.buildImageDownloadUrl(id: id)
                strongSelf.load(url, apiToken: apiToken, completion: { result in
                    switch result {
                    case let .success(response):
                        if let uri = response.body["uri"] as? String {
                            print(uri)
                            completion(uri)
                        } else {
                            completion(nil)
                        }
                    case .failure(let error):
                        print(error)
                        completion(nil)
                    }
                })
            case .failure(let error):
                print(error)
                completion(nil)
            }
        })
    }
    
    func onClearHistory() {
        self.realmStorag.removeAll()
    }
    
    private func buildSearchUrl(searchText: String) -> URL {
        let builder =  URLBuilder(
            path: "/search/images",
            params: [
                "phrase" : searchText,
                "sort_order" : "best_match",
                "fields" : "id, title, thumb",
                "page" : 1,
                "page_size" : 1
            ]
        )
        return builder.build()
    }
    
    private func buildImageDownloadUrl(id: String) -> URL {
        let builder =  URLBuilder(
            path: "/downloads/images/" + id,
            params: ["auto_download" : "false"]
        )
        return builder.build()
    }
    
    private func fetch(_ url: URL, completion: @escaping HttpResponseResultCompletion) {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept" : "application/json",
            "Api-Key" : apiKey,
        ]
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.network(string: "An error occured during request: " + error.localizedDescription)))
            }
            if let data = data {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    if let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let response = HttpResponse(headers: httpResponse.allHeaderFields, body: body)
                        completion(.success(response))
                    } else {
                        completion(.failure(.parser(string: "The body is not JSON")))
                    }
                } catch let error {
                    completion(.failure(.parser(string: error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
    
    private func load(_ url: URL, apiToken: String, completion: @escaping HttpResponseResultCompletion) {
        let apiToken = defaults.string(forKey: keyApiToken)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept" : "application/json",
            "Api-Key" : apiKey,
            "Authorization" : "Bearer " + apiToken!
        ]
        request.httpMethod = "POST"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.network(string: "An error occured during request: " + error.localizedDescription)))
            }
            if let data = data {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    if let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let response = HttpResponse(headers: httpResponse.allHeaderFields, body: body)
                        completion(.success(response))
                    } else {
                        completion(.failure(.parser(string: "The body is not JSON")))
                    }
                } catch let error {
                    completion(.failure(.parser(string: error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
    
    private func oauth2(url: URL, completion: @escaping HttpResponseResultCompletion) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/x-www-form-urlencoded",
        ]
        let params = [
            "client_id" : apiKey,
            "client_secret" : secret,
            "grant_type" : "client_credentials",
        ]
        request.httpBody = params.stringFromHttpParameters().data(using: .utf8)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(.network(string: "An error occured during request: " + error.localizedDescription)))
        }
        if let data = data {
            do {
                print(data)
                let httpResponse = response as! HTTPURLResponse
                if let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let response = HttpResponse(headers: httpResponse.allHeaderFields, body: body)
                        completion(.success(response))
                    } else {
                        completion(.failure(.parser(string: "The body is not JSON")))
                    }
                } catch let error {
                    completion(.failure(.parser(string: error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
    
    private func getTokenFromUserDefaults() -> String? {
        let defaults = UserDefaults.standard
        guard let dateExpiresIn = defaults.value(forKey: keyDateExpiresIn) as? Date,
            dateExpiresIn > Date()
            else {
                return nil
        }
        return defaults.string(forKey: keyApiToken)
    }
    
    private func saveTokenToUserDefaults(_ apiToken: String, expiresIn: Int) {
        let defaults = UserDefaults.standard
        defaults.set(apiToken, forKey: keyApiToken)
        defaults.set(Date().addingTimeInterval(TimeInterval(expiresIn)), forKey: keyDateExpiresIn)
        defaults.synchronize()
    }
    
    private func getNewToken(completion: @escaping NewTokenResultCompletion)  {
        let url = URL(string: urlGetTokenString)
        oauth2(url: url!) { result in
            switch result {
            case let .success(response):
                if let apiToken = response.body["access_token"] as? String,
                    let expiresIn = Int((response.body["expires_in"] as? String) ?? "0.0")
                {
                    completion(.success((token: apiToken, expiresIn: expiresIn)))
                } else {
                    completion(.failure(.parser(string: "The body is not JSON")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getToken(completion: @escaping TokenResultCompletion)  {
        if let token = getTokenFromUserDefaults() {
            completion(.success(token))
        } else {
            getNewToken { result in
                switch result {
                case let .success(token, expiration):
                    self.saveTokenToUserDefaults(token, expiresIn: expiration)
                    completion(.success(token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
