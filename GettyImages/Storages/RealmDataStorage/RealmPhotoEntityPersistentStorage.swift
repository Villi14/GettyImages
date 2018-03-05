//
//  RealmPhotoEntityPersistentStorage.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation
import RealmSwift

class RealmPhotoEntityPersistentStorage: PhotoEntityPersistentStorage {
    let config = Realm.Configuration()
 
    func allPhoto() -> [PhotoEntity] {
        if let realm = try? Realm(configuration: config) {
            let realmPhotos = realm.objects(RealmPhotoEntity.self)
            var photos: [PhotoEntity] = []
            for realmPhoto in realmPhotos {
                let photoEntity = PhotoEntity(
                    searchText: realmPhoto.searchText,
                    id: realmPhoto.id,
                    date: realmPhoto.date,
                    title: realmPhoto.title,
                    uriThumb: realmPhoto.uriThumb,
                    uri: realmPhoto.uri)
                photos.append(photoEntity)
            }
            return photos.sorted(by: { $0.date < $1.date })
        }
        return []
    }
    
    func addPhoto(photo: PhotoEntity) {
        let realmPhotoEntity = RealmPhotoEntity()
        fill(realmPhotoEntity: realmPhotoEntity, withPhotoEntity: photo)
        if let realm = try? Realm(configuration: config) {
            do {
                try realm.write {
                    realm.add(realmPhotoEntity)
                }
            } catch {
                print("Realm save went wrong!")
            }
        }
    }
    
    func removeAll() {
        if let realm = try? Realm(configuration: config) {
            let realmPhotos = realm.objects(RealmPhotoEntity.self)
            do {
                try realm.write {
                    realm.delete(realmPhotos)
                }
            } catch {
                print("Delete went wrong!")
            }
        }
    }
    
    func updatePhoto(photo: PhotoEntity) {
        if let realm = try? Realm(configuration: config) {
            let realmPhotos = realm.objects(RealmPhotoEntity.self).filter("id = %@", photo.id)
            if let realmPhotoEntity = realmPhotos.first {
                do {
                    try realm.write {
                        realmPhotoEntity.uri = photo.uri!
                    }
                } catch {
                    print("Update went wrong!")
                }
            }
        }
    }
    
    private func fill(realmPhotoEntity: RealmPhotoEntity, withPhotoEntity photo: PhotoEntity) {
        realmPhotoEntity.searchText = photo.searchText
        realmPhotoEntity.id = photo.id
        realmPhotoEntity.date = photo.date
        realmPhotoEntity.title = photo.title
        realmPhotoEntity.uriThumb = photo.uriThumb
        if let uri = photo.uri {
            realmPhotoEntity.uri = uri
        }
    }
    
}
