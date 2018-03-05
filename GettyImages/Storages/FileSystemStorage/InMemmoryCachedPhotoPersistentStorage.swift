//
//  InMemmoryCachedPhotoPersistentStorage.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class InMemmoryCachedPhotoPersistentStorage: PhotoPersistentStorage {
    fileprivate var cache: [String: UIImage] = [:]
    fileprivate var storage: PhotoPersistentStorage
    var notificationCenter: NotificationCenter = NotificationCenter.default
    init(storage: PhotoPersistentStorage) {
        self.storage = storage
        notificationCenter.addObserver(
            self,
            selector: #selector(clearCache(_:)),
            name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
            object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func addImage(_ image: UIImage, withKey key: String) {
        self.storage.addImage(image, withKey: key)
        cache[key] = image
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        if let image = cache[key] {
            return image
        }
        return self.storage.imageForKey(key)
    }
    
    func deleteImageWithKey(_ key: String) -> Bool {
        _ = self.storage.deleteImageWithKey(key)
        if let key = cache.index(forKey: key) {
            cache.remove(at: key)
        }
        return true
    }
    
    @objc fileprivate func clearCache(_ notification: NotificationCenter) {
        cache.removeAll()
    }
}
