//
//  PhotoPersistentStorage.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

protocol PhotoPersistentStorage {
    func addImage(_ image: UIImage, withKey: String)
    func imageForKey(_ key: String) -> UIImage?
    func deleteImageWithKey(_ key: String) -> Bool
}
