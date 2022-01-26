//
//  Request.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation

protocol Request {
    var baseURL: URL? { get }
    var path: String { get }
    var timeoutInterval: TimeInterval { get }
    var queryItems: [ String : String ] { get }

    static var defaultRetryCount: Int { get }

    func url() throws -> URL
    func request() throws -> URLRequest
}

// MARK: Default values
extension Request {
    var timeoutInterval: TimeInterval {
        return 15.0
    }

    var queryItems: [String : String] {
        return [:]
    }

    static var defaultRetryCount: Int {
        3
    }

    func url() throws -> URL {
        var components = URLComponents()
        components.path = path

        components.queryItems = queryItems.map({ name, value -> URLQueryItem in
            return URLQueryItem(name: name, value: value)
        })
        guard let url = components.url(relativeTo: baseURL) else {
            throw NetworkErrors.failedToContructURL
        }

        return url
    }

    func request() throws -> URLRequest {
        return URLRequest(url: try url(), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
    }
}

// MARK: Functions
extension Request {

    private func handleErrors(_ data: Data?, _ error: Error?) throws -> Data {
        if let error = error {
            throw error
        }

        guard let data = data else { throw NetworkErrors.noDataReturned }

        if String(data: data, encoding: .ascii)?.contains("Server overloaded") == true {
            throw NetworkErrors.serverIsOverloaded
        }

        return data
    }

    func submit<T>(dispatchQueue: DispatchQueue,
                   retryCount: Int = Self.defaultRetryCount,
                   completion: @escaping (Result<T, Error>) -> Void,
                   requestHandler: @escaping (Data, URLResponse?) throws -> T) {
        do {
            let request = try self.request()
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let data = try self.handleErrors(data, error)

                    let result = try requestHandler(data, response)
                    dispatchQueue.async {
                        completion(.success(result))
                    }
                } catch NetworkErrors.serverIsOverloaded where retryCount != 0 {
                    self.submit(dispatchQueue: dispatchQueue, retryCount: retryCount-1, completion: completion, requestHandler: requestHandler)
                } catch {
                    dispatchQueue.async {
                        completion(.failure(error))
                    }
                }
            }.resume()
        } catch {
            dispatchQueue.async {
                completion(.failure(error))
            }
        }
    }

    func submit<T: Decodable>(dispatchQueue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<T,Error>) -> Void ) {
        self.submit(dispatchQueue: dispatchQueue, completion: completion) { (data, response) -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
}
