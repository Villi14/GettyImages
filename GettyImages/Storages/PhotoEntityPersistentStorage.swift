//
//  PhotoEntityPersistentStorage.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

protocol PhotoEntityPersistentStorage {
    func allPhoto() -> [PhotoEntity]
    func addPhoto(photo: PhotoEntity)
    func updatePhoto(photo: PhotoEntity)
    func removeAll()
}
