//
//  RealmPhotoEntity.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation
import RealmSwift

class RealmPhotoEntity: Object {
    @objc dynamic var searchText = ""
    @objc dynamic var id = ""
    @objc dynamic var date = Date()
    @objc dynamic var title = ""
    @objc dynamic var uriThumb = ""
    @objc dynamic var uri = ""
}

