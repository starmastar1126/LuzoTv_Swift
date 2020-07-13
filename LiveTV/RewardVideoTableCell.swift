//
//  RewardVideoTableCell.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 19/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class RewardVideoTableCell: UITableViewCell,UICollectionViewDelegate
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
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CommonUtils.screenWidth/3.5), collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "RewardCell_iPad", bundle:nil)
            self.collectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "RewardCell", bundle:nil)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! RewardCell
        
        let strimgpath : String? = (self.CollectionArray.value(forKey: "video") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        
        if let iamge = self.getThumbnailImage(forUrl: url!) {
             cell.iconImageView?.image = iamge
        } else {
            cell.iconImageView?.image = nil
        }
       
        
        //cell.lblRewardName?.text = (self.CollectionArray.value(forKey: "series_name") as! NSArray).object(at: indexPath.row) as? String
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (CommonUtils.screenWidth-40)/2, height: CommonUtils.screenWidth/3.5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let videoID = (self.CollectionArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        
        NotificationCenter.default.post(name: Notification.Name("RewardCellClick"), object: nil, userInfo: ["id": videoID as Any])
    }
    
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
