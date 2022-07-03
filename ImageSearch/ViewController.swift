//
//  ViewController.swift
//  PhotoSearch
//
//  Created by Nikolai Eremenko on 01.07.2022.
//

import UIKit

struct SearchResults: Codable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashPhoto]
}
struct UnsplashPhoto: Codable {
    let id: String
    let urls: URlS
}
struct URlS: Codable {
    let regular: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
    private var collectionView: UICollectionView?
    let search = UISearchBar()
    var results: [UnsplashPhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifire)
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.collectionView = collectionView
        search.delegate = self
        view.addSubview(search)
    }
    
    func searchBarSearchButtonClicked(_ search: UISearchBar) {
        search.resignFirstResponder()
        if let text = search.text {
            results = []
            collectionView?.reloadData()
            fetchPhotos(quary: text)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        search.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 40)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }
    
    func fetchPhotos(quary: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(quary)&client_id=EnterAccessKeyHere"
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(SearchResults.self, from: data)
//                print(jsonResult.results.count)
                DispatchQueue.main.async {
                    self?.results = jsonResult.results
                    self?.collectionView?.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = results[indexPath.row].urls.regular
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifire,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageURLString)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
}
