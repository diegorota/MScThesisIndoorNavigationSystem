//
//  HomeViewController.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class HomeViewController: UICollectionViewController {
    
    var tiles = [HomeTile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hospital"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings"), style: .done, target: self, action: #selector(openSettings))
        loadTiles()

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tile", for: indexPath) as! TileCell
        cell.titleLabel.text = tiles[indexPath.item].titleTile
        cell.descriptionLabel.text = tiles[indexPath.item].descriptionTile
        cell.callToActionLabel.text = tiles[indexPath.item].callToActionTile
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func openSettings() {
        
        if let settings = storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController {
            navigationController?.pushViewController(settings, animated: true)
        }
        
        
    }
    
    // Funzione che carica il file JSON contenente le informazioni delle tiles, crea un oggetto HomeTile per ogni tile e lo inserisce nell'array tiles.
    // Attualmente la funzione non legge un file JSON ma crea manualmente due tile.
    func loadTiles() {
        
        if let path = Bundle.main.path(forResource: "json/homepage", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    func parse(json: JSON) {
        for tile in json.arrayValue {
            let homeTile = HomeTile(titleTile: tile["tilename"].stringValue, descriptionTile: tile["action"].stringValue, callToActionTile: tile["action"].stringValue, logoTile: tile["logo"].stringValue, dimensionTile: tile["dimension"].intValue)
            tiles.append(homeTile)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
