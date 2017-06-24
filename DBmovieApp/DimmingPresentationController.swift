//
//  DimmingPresentationController.swift
//  DBmovieApp
//
//  Created by Dmitriy on 03/05/2017.
//  Copyright © 2017 Dmitriy. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    // overrides some of default behavior for presenting new view controllers, this telling UIKit to leave the SearchViewController visible
    override var shouldRemovePresentersView: Bool {
        return false
    }
}





