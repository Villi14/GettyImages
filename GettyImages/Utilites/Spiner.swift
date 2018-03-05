//
//  Spinner.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class Spinner {
    static func changeState(spinner: UIActivityIndicatorView?, isShow: Bool) {
        if let spinner = spinner {
            DispatchQueue.main.async {
                if isShow {
                    spinner.startAnimating()
                } else {
                    spinner.stopAnimating()
                }
                spinner.isHidden = !isShow
            }
        }
    }
}

