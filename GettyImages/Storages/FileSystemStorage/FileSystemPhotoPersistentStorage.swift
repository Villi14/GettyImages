//
//  FileSystemPhotoPersistentStorage.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

private func filePathForImageWithKey(_ key: String) -> String {
    let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
    return (docURL?.appendingPathComponent("\(key)").path)!
}

class FileSystemPhotoPersistentStorage: PhotoPersistentStorage {
    fileprivate let fileManager: FileManager = FileManager.default
    
    func addImage(_ image: UIImage, withKey key: String) {
        if let data = UIImagePNGRepresentation(image) {
            let path = filePathForImageWithKey(key)
            do {
                 try data.write(to: URL(fileURLWithPath: path), options: [])
            } catch(let error) {
                print(error)
            }
        }
    }
    
    func imageForKey(_ key: String) -> (UIImage)? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePathForImageWithKey(key))) else {
            return nil
        }
        let image = UIImage(data: data)
        return (image!)
    }
    
    func deleteImageWithKey(_ key: String) -> Bool {
        do {
            try fileManager.removeItem(atPath: filePathForImageWithKey(key))
            return true
        } catch {
            return false
        }
    }
}
