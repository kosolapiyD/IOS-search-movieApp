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
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // add 64 point margin at the top
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        searchBar.resignFirstResponder()
        
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.title = String(format: "fake result %d for ", i)
            searchResult.releaseDate = searchBar.text!
            searchResults.append(searchResult)
        }
        hasSearched = true
        tableView.reloadData()
    }
}
// MARK: -> table view data source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing Found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.title
            cell.detailTextLabel!.text = searchResult.releaseDate
        }
        return cell
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
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}











