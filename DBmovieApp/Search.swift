//
//  Search.swift
//  DBmovieApp
//
//  Created by Dmitriy on 24/06/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            // If there was an active data task this cancels it, making sure that no old searches can ever get in the way of the new search
            dataTask?.cancel()
            
            // before the networking request, set isLoading to true and reload the table to show the activity indicator
            isLoading = true
            hasSearched = true
            searchResults = []
            
            let url = searchMovieUrl(searchText: text)
            
            // get URLSession object. standart 'shared' session which uses default configuration
            let session = URLSession.shared
            // create dataTask, for sending HTTPS GET requests to the server at url
            // code from the completion handler will be invoked when the data task has received the reply from the server
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                
                var success = false
                
                if let error = error as? NSError, error.code == -999 {
                    print("Failure! \(error)")
                    return // previous search was canceled just ignore the code ' -999 '
                    // check to make sure the HTTP response code really was 200
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                        //print("Succes! \(data)")
                    let jsonData = data,
                    let jsonDictionary = self.parse(json: jsonData) {
                    
                    self.searchResults = self.parse(dictionary: jsonDictionary)
                    self.searchResults.sort(by: { (v1, v2) -> Bool in
                        return v1.voteAverage > v2.voteAverage
                    })
                    self.isLoading = false
                    success = true
                }
                if !success {
                    print("Failure! \(response)")
                    self.hasSearched = false
                    self.isLoading = false
                }
                DispatchQueue.main.async {
                    completion(success)
                }
            })
            dataTask?.resume() // start the dataTask, this sends request to the server
            // and URLSession is Asynchronous by default, so all this happens on background thread
        }
    }
    
    
    func searchMovieUrl(searchText: String) -> URL {
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format: "https://api.themoviedb.org/3/search/movie?api_key=0a738c97e3cf186d7e0f405b74272e82&language=en-US&query=%@&page=1&include_adult=true", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    
    func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON eror: \(error)")
            return nil
        }
    }
    
    // array of searchResults
    func parse(dictionary: [String: Any]) -> [SearchResult] {
        
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        
        for resultDict in array {
            
            if let resultDict = resultDict as? [String: Any] {
                
                var searchResult: SearchResult?
                
                searchResult = parse(movie: resultDict) // parse movie
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    // single object { dictionary } of searchResult
    func parse(movie dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.title = dictionary["title"] as! String
        searchResult.releaseDate = dictionary["release_date"] as! String
        searchResult.overview = dictionary["overview"] as! String
        
        if let poster = dictionary["poster_path"] as? String {
            searchResult.posterPath = poster
        }
        
        if let vote = dictionary["vote_average"] as? Double {
            searchResult.voteAverage = vote
        }
        
        if let genre = dictionary["genre_ids"] as? [Int] {
            let first = genre.first
            
            if first == nil {
                searchResult.genre = ""
                
            } else {
                searchResult.genre = String(first!)
            }
            switch searchResult.genre {
            case "28" : searchResult.genre = "Action"
            case "12" : searchResult.genre = "Adventure"
            case "16" : searchResult.genre = "Animation"
            case "35" : searchResult.genre = "Comedy"
            case "80" : searchResult.genre = "Crime"
            case "99" : searchResult.genre = "Documentary"
            case "18" : searchResult.genre = "Drama"
            case "10751" : searchResult.genre = "Family"
            case "14" : searchResult.genre = "Fantasy"
            case "36" : searchResult.genre = "History"
            case "27" : searchResult.genre = "Horror"
            case "10402" : searchResult.genre = "Music"
            case "9648" : searchResult.genre = "Mystery"
            case "10749" : searchResult.genre = "Romance"
            case "878" : searchResult.genre = "Science Fiction"
            case "10770" : searchResult.genre = "TV Movie"
            case "53" : searchResult.genre = "Thriller"
            case "10752" : searchResult.genre = "War"
            case "37" : searchResult.genre = "Western"
            default : searchResult.genre = "No genre"
            }
            
        }
        return searchResult
    }
    
}
