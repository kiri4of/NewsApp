//
//  APICaller.swift
//  NewsApp
//
//  Created by Kiri4of on 05.01.2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=9ec4f0082d294c3abd65028cf008af16")
        static let searchUrlString = "https://newsapi.org/v2/everything?sortBy=popularity&apiKey=9ec4f0082d294c3abd65028cf008af16&q="
    }
    
    private init () {}
    public func getStories(complition: @escaping (Result<[Article],Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                complition(.failure(error))
            }
            else if let data = data{
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    complition(.success(result.articles))
                }
                catch {
                    complition(.failure(error))
                }
            }
        }
        task.resume()
    }
    public func search(with query: String, complition: @escaping (Result<[Article],Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {return} //убрать пустые пробелы
        let urlString = Constants.searchUrlString + query
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                complition(.failure(error))
            }
            else if let data = data{
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    complition(.success(result.articles))
                }
                catch {
                    complition(.failure(error))
                }
            }
        }
        task.resume()
    }
}


//Models

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}
 
struct Source: Codable {
    let name: String
}
