//
//  SearchPhotoViewController.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/1/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

protocol SearchProvider {
    func onDidLoad() -> [PhotoEntity]
    func onSearch(text: String, completion: @escaping (PhotoEntity?) -> Void)
    func onDownload(id: String, completion: @escaping (String?) -> Void )
    func onClearHistory()
}

class SearchPhotoViewController: UIViewController {
    private var searchText: String?
    private var searchPhotoProvider = SearchPhotoProvider()
    private var listPhotoEntity = [PhotoEntity]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    lazy private var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        return table
    }()
    lazy private var clearHistory: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear History", for: .normal)
        button.addTarget(self, action: #selector(touchClearHostory), for: .touchUpInside)
        return button
    }()
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = view.center
        return spinner
    }()
    
    private var inMemoryCache: InMemmoryCachedPhotoPersistentStorage!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        listPhotoEntity = searchPhotoProvider.onDidLoad()
        setupSearchController()
        view.addSubview(tableView)
        view.addSubview(clearHistory)
        view.addSubview(spinner)
        setupAutoLayout()
        
        let fileSystemStorage = FileSystemPhotoPersistentStorage()
        inMemoryCache = InMemmoryCachedPhotoPersistentStorage(storage: fileSystemStorage)
    }
    
    private func setupAutoLayout() {
        //tableView
        let attributes: [NSLayoutAttribute] = [.top, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(
                item: tableView,
                attribute: $0,
                relatedBy: .equal,
                toItem: view,
                attribute: $0,
                multiplier: 1.0,
                constant: 0.0)
        })
        let bottomTable = NSLayoutConstraint(
            item: tableView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -44.0)
        // Button
        let leadingButton = NSLayoutConstraint(
            item: clearHistory,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0)
        let trailingButton = NSLayoutConstraint(
            item: clearHistory,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0)
        let bottomButton = NSLayoutConstraint(
            item: clearHistory,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottomMargin,
            multiplier: 1.0,
            constant: 0.0)
        let heightButton = NSLayoutConstraint(
            item: clearHistory,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 44)
        NSLayoutConstraint.activate([bottomTable])
        NSLayoutConstraint.activate([leadingButton, trailingButton, bottomButton, heightButton])
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search Photo"
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    @objc private func touchClearHostory() {
        searchPhotoProvider.onClearHistory()
        listPhotoEntity = []
    }
}

extension SearchPhotoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPhotoEntity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let photoEntity = listPhotoEntity[indexPath.row]
        cell.textLabel?.text = photoEntity.searchText
        cell.detailTextLabel?.text = photoEntity.title.trunc(length: 30)
        if let image = inMemoryCache.imageForKey(photoEntity.id + "Thumb") {
            DispatchQueue.main.async {
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        } else {
            loadImage(photoEntity, cell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoViewController = PhotoViewController()
        listPhotoEntity = searchPhotoProvider.onDidLoad()
        photoViewController.photoEntity = listPhotoEntity[indexPath.row]
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    fileprivate func loadImage(_ photoEntity: PhotoEntity, _ cell: UITableViewCell) {
        let url = URL(string: photoEntity.uriThumb)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            if let image = UIImage(data: data!) {
                let resizeImage = image.resizedImage(newSize: CGSize(width: 80.0, height: 55.0))
                self.inMemoryCache.addImage(resizeImage, withKey: photoEntity.id + "Thumb" )
                DispatchQueue.main.async {
                    cell.imageView?.image = resizeImage
                    cell.setNeedsLayout()
                }
            }
        }
    }
}

extension SearchPhotoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension SearchPhotoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchText = searchBar.text
        Spinner.changeState(spinner: spinner, isShow: true)
        searchPhotoProvider.onSearch(text: self.searchText ?? "") {[weak self] photoEntity  in
            Spinner.changeState(spinner: self?.spinner, isShow: false)
            if let photoEntity = photoEntity {
                self?.listPhotoEntity.append(photoEntity)
            } else {
                Alert.displayIn(self, title: "Failure", message: "photo not found")
            }
        }
    }
}
