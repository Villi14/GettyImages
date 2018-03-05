//
//  Spiner.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class Spiner {
    static func changeState(spiner: UIActivityIndicatorView?, isShow: Bool) {
        if let spiner = spiner {
            DispatchQueue.main.async {
                if isShow {
                    spiner.startAnimating()
                } else {
                    spiner.stopAnimating()
                }
                spiner.isHidden = !isShow
            }
        }
    }
}

