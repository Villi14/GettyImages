//
//  PhotoViewController.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var photoEntity: PhotoEntity!
    private var searchPhotoProvider = SearchPhotoProvider()
    private var inMemoryCache: InMemmoryCachedPhotoPersistentStorage!
    lazy private var photo: UIImageView = {
        let photo = UIImageView(frame: .zero)
        photo.contentMode = .scaleAspectFit
        photo.translatesAutoresizingMaskIntoConstraints = false
        return photo
    }()
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = view.center
        return spinner
    }()
    lazy private var realmStorage = RealmPhotoEntityPersistentStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        let fileSystemStorage = FileSystemPhotoPersistentStorage()
        inMemoryCache = InMemmoryCachedPhotoPersistentStorage(storage: fileSystemStorage)
        
        if let uri = photoEntity.uri, uri != "" {
            DispatchQueue.main.async {
                let image = self.inMemoryCache.imageForKey(self.photoEntity.id)
                self.photo.image = image
            }
        } else {
            dowload()
        }
        view.backgroundColor = .white
        view.addSubview(photo)
        view.addSubview(spinner)
        setupAutoLayout()
    }
    
    private func setupAutoLayout() {
        let attributes: [NSLayoutAttribute] = [.top, .bottom, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(
                item: photo,
                attribute: $0,
                relatedBy: .equal,
                toItem: view,
                attribute: $0,
                multiplier: 1.0,
                constant: 0.0)
        })
    }
    
    fileprivate func dowload() {
        Spinner.changeState(spinner: self.spinner, isShow: true)
        searchPhotoProvider.onDownload(id: photoEntity.id) { [weak self]  uri in
            guard let strongSelf = self else { return }
            Spinner.changeState(spinner: strongSelf.spinner, isShow: false)
            if let uri = uri {
                strongSelf.photoEntity.uri = uri
                if let image = strongSelf.inMemoryCache.imageForKey(strongSelf.photoEntity.id) {
                    DispatchQueue.main.async {
                        strongSelf.photo.image = image
                    }
                } else {
                    strongSelf.downloadImage(strongSelf.photoEntity)
                }
            } else {
                 Alert.displayIn(self, title: "Failure", message: "photo not found")
            }
        }
    }
    
    fileprivate func downloadImage(_ photoEntity: PhotoEntity) {
        let url = URL(string: photoEntity.uri!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            if let image = UIImage(data: data!) {
                self.inMemoryCache.addImage(image, withKey: photoEntity.id)
                self.realmStorage.updatePhoto(photo: photoEntity)
                DispatchQueue.main.async {
                    self.photo.image = image
                }
            }
        }
    }
}
