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
    //var searchResult = SearchResult()
    
    var hasSearched = false
    var isLoading = false

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
    
    func performMovieDbRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }
        
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
    
    func parse(dictionary: [String: Any]) -> [SearchResult] {
        
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        
        for resultDict in array {
            
            if let resultDict = resultDict as? [String: Any] {
                
                var searchResult: SearchResult?
                
                searchResult = parse(movie: resultDict)
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    func parse(movie dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.title = dictionary["title"] as! String
        searchResult.releaseDate = dictionary["release_date"] as! String
        
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
            
            // before the networking request, set isLoading to true and reload the table to show the activity indicator
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let queue = DispatchQueue.global()
            
            queue.async { // code is in this closure will be put on the queue and be executed asynchronously on the background
                let url = self.searchMovieUrl(searchText: searchBar.text!)
            
                if let jsonString = self.performMovieDbRequest(with: url) {
                    if let jsonDictionary = self.parse(json: jsonString) {
                        
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        // searchResults sorted by voteAverage
                        self.searchResults.sort(by: { (res1, res2) -> Bool in
                            return res1.voteAverage > res2.voteAverage
                        })
                        DispatchQueue.main.async { // get back to the main queue
                            // all the UI code should always run on main thread
                            self.isLoading = false
                            self.tableView.reloadData()
                            // after the request completes set isLoading back to false and reload the table again to show the SearchResult objects
                        }
                        return
                    }
                }
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            }
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
            cell.titleLabel.text = searchResult.title
            cell.releaseDateLabel.text = searchResult.releaseDate
            cell.voteLabel.text = String(searchResult.voteAverage) + " votes"
            cell.genreLabel.text = searchResult.genre
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











