//
//  SearchViewController.swift
//  DBmovieApp
//
//  Created by Dmitriy on 01/05/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var dataTask: URLSessionDataTask?
    
    var hasSearched = false
    var isLoading = false
    
    var posterBaseUrl = "https://image.tmdb.org/t/p/w45"

    override func viewDidLoad() {
        super.viewDidLoad()
        // add 64 point margin at the top
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        // load the nib (custom cells)
        var cellNib = UINib(nibName: CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.loadingCell)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // struct with identifier constants
    struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
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
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from The Movie DB. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
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

// MARK: -> EXTENSIONS
// MARK: -> search bar delegate
extension SearchViewController: UISearchBarDelegate {
    // paints the white gap above the search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // hide the keybord until tap inside the search bar
        // searchBar.resignFirstResponder()
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            // If there was an active data task this cancels it, making sure that no old searches can ever get in the way of the new search
            dataTask?.cancel()
            // before the networking request, set isLoading to true and reload the table to show the activity indicator
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
        
            // create the url object with search text
            let url = searchMovieUrl(searchText: searchBar.text!)
            // get URLSession object. standart 'shared' session which uses default configuration
            let session = URLSession.shared
            // create dataTask, for sending HTTPS GET requests to the server at url
            // code from the completion handler will be invoked when the data task has received the reply from the server
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error as? NSError, error.code == -999 {
                    print("Failure! \(error)")
                    return // previous search was canceled just ignore the code ' -999 '
                    // check to make sure the HTTP response code really was 200
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        //print("Succes! \(data)")
                        if let data = data {
                            if let jsonDictionary = self.parse(json: data) {
                                self.searchResults = self.parse(dictionary: jsonDictionary)
                                self.searchResults.sort(by: { (v1, v2) -> Bool in
                                    return v1.voteAverage > v2.voteAverage
                                })
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    self.tableView.reloadData()
                                }
                                return
                            }
                        }
                    } else {
                        print("Failure! \(response)")
                    }
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            dataTask?.resume() // start the dataTask, this sends request to the server
            // and URLSession is Asynchronous by default, so all this happens on background thread
        }
    }
}
// MARK: -> table view data source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        //if searchBar.text! == "Not"
        else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.nothingFoundCell, for: indexPath) // custom cell nib 'Nothing Found'
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell // custom nib cell
            
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
}
// MARK: -> table view delegate
extension SearchViewController: UITableViewDelegate {
    // deselct the row with animation, not selected all the time
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // makes sure that can only select rows with actual search results
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}











