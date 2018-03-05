//
//  UIImageExt.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/3/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        let rect = CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height)
        self.draw(in: rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
