//
//  SeriesTableCell.swift
//  LiveTV
//
//  Created by Apple on 13/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class SeriesTableCell: UITableViewCell,UICollectionViewDelegate
    ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    @IBOutlet var collectionView: UICollectionView!
    var CollectionArray = NSArray()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CommonUtils.screenWidth/2.5), collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "SeriesCell_iPad", bundle:nil)
            self.collectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "SeriesCell", bundle:nil)
            self.collectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
    }
    
    func setCollectionData(_ collectionData: [Any]?)
    {
        self.CollectionArray = collectionData! as NSArray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
    }
    
    //============UICollectionView Delegate & Datasource Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.CollectionArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! SeriesCell
        
        let strimgpath : String? = (self.CollectionArray.value(forKey: "series_poster") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        cell.lblSeriesName?.text = (self.CollectionArray.value(forKey: "series_name") as! NSArray).object(at: indexPath.row) as? String
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/2.5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let seriesID = (self.CollectionArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(seriesID, forKey: "SERIES_ID")
        let seriesNAME = (self.CollectionArray.value(forKey: "series_name") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(seriesNAME, forKey: "SERIES_NAME")
        NotificationCenter.default.post(name: Notification.Name("SeriesCellClick"), object: nil, userInfo: ["id": seriesID as Any])
    }
}
