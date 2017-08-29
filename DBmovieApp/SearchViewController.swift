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
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        print(segmentedControl.selectedSegmentIndex)
        
        // performSearch()
        
//        switch segmentedControl.selectedSegmentIndex {
//            
//            // popular
//        case 0 : segmentUrl = URL(string : "https://api.themoviedb.org/3/discover/movie?api_key=0a738c97e3cf186d7e0f405b74272e82&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1")
//                        // drama
//        case 1 : segmentUrl = URL(string : "https://api.themoviedb.org/3/discover/movie?api_key=0a738c97e3cf186d7e0f405b74272e82&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=18")
//   
//            // horror
//        case 2 : segmentUrl = URL(string : "https://api.themoviedb.org/3/discover/movie?api_key=0a738c97e3cf186d7e0f405b74272e82&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=27")
//            
//            // animation
//        case 3 : segmentUrl = URL(string : "https://api.themoviedb.org/3/discover/movie?api_key=0a738c97e3cf186d7e0f405b74272e82&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=16")
//            
//            default: break
//        }
    }
    
    //var segmentUrl: URL!

    
    let search = Search()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // add 64 point (searchBar) margin at the top // and 44 points is the navBar
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()

    }
    
    
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from The Movie DB. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
}

// MARK: -> EXTENSIONS
// MARK: -> search bar delegate
extension SearchViewController: UISearchBarDelegate {
    // paints the white gap above the search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func performSearch() {
        // hide the keybord until tap inside the search bar
        // searchBar.resignFirstResponder()
        search.performSearch(for: searchBar.text!, completion: { success in
            
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

// MARK: -> table view data source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
            return 1
        } else {
            return search.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        //if searchBar.text! == "Not"
        else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.nothingFoundCell, for: indexPath) // custom cell nib 'Nothing Found'
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell // custom nib cell
            
            let searchResult = search.searchResults[indexPath.row]
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
    
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    // makes sure that can only select rows with actual search results
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}











