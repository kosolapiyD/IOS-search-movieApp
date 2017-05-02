//
//  PosterDownload.swift
//  DBmovieApp
//
//  Created by Dmitriy on 02/05/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadPoster(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url,
                                                completionHandler: { [weak self] url, response, error in
            
            if error == nil, let url = url,
                             let data = try? Data(contentsOf: url),
                             let poster = UIImage(data: data) {
                
                            DispatchQueue.main.async {
                                if let strongSelf = self {
                                    strongSelf.image = poster
                                }
                            }
                        }
                     })
        downloadTask.resume()
        return downloadTask
    }
}





