//
//  DetailViewController.swift
//  DBmovieApp
//
//  Created by Dmitriy on 03/05/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!

    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // As usual, this is an implicitly-unwrapped optional because you won’t know what its value will be until the segue is performed. It is nil in the mean time.
    var searchResult: SearchResult!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 218/255, green: 76/255, blue: 56/255, alpha: 1)
        popUpView.layer.cornerRadius = 10
     
        // this creates the new gesture recognizer that listens to taps anywhere in this view controller and calls the close() method in response
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)

        // the if != nil check is a defensive measure, just in case the developer forgets to fill in searchResult on the segue
        if searchResult != nil {
            updateUI() }
        
    }
    
    // Recall that init?(coder) is invoked to load the view controller from the storyboard. Here you tell UIKit that this view controller uses a custom presentation and you set the delegate that will call the method you just implemented
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    let posterBaseUrl = "https://image.tmdb.org/t/p/w342"
    
    func updateUI() {
        overviewLabel.text = searchResult.overview
        
        if let posterURL = URL(string: posterBaseUrl + searchResult.posterPath) {
            downloadTask = posterImage.loadPoster(url: posterURL)
        }
    }
    
    deinit {
        print("deinit\(self)")
        // cancel the image download if the user closes the pop-up before the image has been downloaded completely
        downloadTask?.cancel()
    }

}


extension DetailViewController: UIViewControllerTransitioningDelegate {
    // The methods from this delegate protocol tell UIKit what objects it should use to perform the transition to the Detail View Controller. It will now use your new DimmingPresentationController class instead of the standard presentation controller
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        // tell the app that you want to use your own presentation controller to show the Detail pop-up
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // returns true when the touch was on the background view but false if it was inside the Pop-up View
        // page 141
        return (touch.view === self.view)
    }
}






