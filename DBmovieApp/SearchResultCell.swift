//
//  SearchResultCell.swift
//  DBmovieApp
//
//  Created by Dmitriy on 01/05/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // all table view cells have a selectedBackgroundView property and is placed on top of cells background
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 218/255, green: 76/255, blue: 56/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let posterBaseUrl = "https://image.tmdb.org/t/p/w45"
    
    func configure(for searchResult: SearchResult) {
        
        titleLabel.text = searchResult.title
        releaseDateLabel.text = searchResult.releaseDate
        voteLabel.text = String(searchResult.voteAverage) + " votes"
        genreLabel.text = searchResult.genre
        
        posterImageView.image = UIImage(named: "Placeholder")
        if let posterURL = URL(string: posterBaseUrl + searchResult.posterPath) {
            downloadTask = posterImageView.loadPoster(url: posterURL)
        }
    }
    // theoretically possible that you’re scrolling through the table and some cell is about to be reused while its previous image is still loading
    // this cancel any image download that is still in progress
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
    }

}
