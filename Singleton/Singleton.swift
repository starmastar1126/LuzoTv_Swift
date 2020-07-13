//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

let sharedInstance = Singleton()

class Singleton: NSObject
{
    var database: FMDatabase? = nil
    class func getInstance() -> Singleton
    {
        if (sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: CommonUtils.getPath("LiveTV.sqlite"))
        }
        return sharedInstance
    }
    
    //1.Movies Favourites
    func InsertMoviesQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let insertquy = sharedInstance.database!.executeUpdate("INSERT INTO Favourite_Movies (mid, movie_title, language_name, language_background, movie_cover, movie_cover_thumb, movie_poster, movie_poster_thumb) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [modalObj.mid as Any, modalObj.movie_title as Any, modalObj.language_name as Any, modalObj.language_background as Any, modalObj.movie_cover as Any, modalObj.movie_cover_thumb as Any, modalObj.movie_poster as Any, modalObj.movie_poster_thumb as Any])
        sharedInstance.database!.close()
        return insertquy
    }
    func SingleMoviesQueryData(_ modalObj: Modal) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Movies WHERE mid=?", withArgumentsIn: [modalObj.mid as Any])
        let MoviesInfoArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let modalObj : Modal = Modal()
                modalObj.mid = resultSet.string(forColumn: "mid")
                MoviesInfoArray.add(modalObj)
            }
        }
        sharedInstance.database!.close()
        return MoviesInfoArray
    }
    func DeleteMoviesQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM Favourite_Movies WHERE mid=?", withArgumentsIn: [modalObj.mid as Any])
        sharedInstance.database!.close()
        return isDeleted
    }
    func getAllMoviesQueryData() -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Movies", withArgumentsIn: [])
        let AllMoviesArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                /*let modalObj : Modal = Modal()
                modalObj.mid = resultSet.string(forColumn: "mid")
                modalObj.movie_title = resultSet.string(forColumn: "movie_title")
                modalObj.language_name = resultSet.string(forColumn: "language_name")
                modalObj.language_background = resultSet.string(forColumn: "language_background")
                modalObj.movie_cover = resultSet.string(forColumn: "movie_cover")
                modalObj.movie_cover_thumb = resultSet.string(forColumn: "movie_cover_thumb")
                modalObj.movie_poster = resultSet.string(forColumn: "movie_poster")
                modalObj.movie_poster_thumb = resultSet.string(forColumn: "movie_poster_thumb")
                AllMoviesArray.add(modalObj)*/
                
                let id = resultSet.string(forColumn: "mid")
                let movie_title = resultSet.string(forColumn: "movie_title")
                let language_name = resultSet.string(forColumn: "language_name")
                let language_background = resultSet.string(forColumn: "language_background")
                let movie_cover = resultSet.string(forColumn: "movie_cover")
                let movie_cover_thumb = resultSet.string(forColumn: "movie_cover_thumb")
                let movie_poster = resultSet.string(forColumn: "movie_poster")
                let movie_poster_thumb = resultSet.string(forColumn: "movie_poster_thumb")
                let dict : NSDictionary = [
                    "id" : id as Any,
                    "movie_title" : movie_title as Any,
                    "language_name" : language_name as Any,
                    "language_background" : language_background as Any,
                    "movie_cover" : movie_cover as Any,
                    "movie_cover_thumb" : movie_cover_thumb as Any,
                    "movie_poster" : movie_poster as Any,
                    "movie_poster_thumb" : movie_poster_thumb as Any]
                AllMoviesArray.add(dict)
            }
        }
        sharedInstance.database!.close()
        return AllMoviesArray
    }
    
    //2.Series Favourites
    func InsertSeriesQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let insertquy = sharedInstance.database!.executeUpdate("INSERT INTO Favourite_Series (sid, series_name, series_cover, series_cover_thumb, series_poster, series_poster_thumb) VALUES (?, ?, ?, ?, ?, ?)", withArgumentsIn: [modalObj.sid as Any, modalObj.series_name as Any, modalObj.series_cover as Any, modalObj.series_cover_thumb as Any, modalObj.series_poster as Any, modalObj.series_poster_thumb as Any])
        sharedInstance.database!.close()
        return insertquy
    }
    func SingleSeriesQueryData(_ modalObj: Modal) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Series WHERE sid=?", withArgumentsIn: [modalObj.sid as Any])
        let SeriesInfoArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let modalObj : Modal = Modal()
                modalObj.sid = resultSet.string(forColumn: "sid")
                SeriesInfoArray.add(modalObj)
            }
        }
        sharedInstance.database!.close()
        return SeriesInfoArray
    }
    func DeleteSeriesQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM Favourite_Series WHERE sid=?", withArgumentsIn: [modalObj.sid as Any])
        sharedInstance.database!.close()
        return isDeleted
    }
    func getAllSeriesQueryData() -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Series", withArgumentsIn: [])
        let AllSeriesArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                /*let modalObj : Modal = Modal()
                modalObj.sid = resultSet.string(forColumn: "sid")
                modalObj.series_name = resultSet.string(forColumn: "series_name")
                modalObj.series_cover = resultSet.string(forColumn: "series_cover")
                modalObj.series_cover_thumb = resultSet.string(forColumn: "series_cover_thumb")
                modalObj.series_poster = resultSet.string(forColumn: "series_poster")
                modalObj.series_poster_thumb = resultSet.string(forColumn: "series_poster_thumb")
                AllSeriesArray.add(modalObj)*/
                
                let id = resultSet.string(forColumn: "sid")
                let series_name = resultSet.string(forColumn: "series_name")
                let series_cover = resultSet.string(forColumn: "series_cover")
                let series_cover_thumb = resultSet.string(forColumn: "series_cover_thumb")
                let series_poster = resultSet.string(forColumn: "series_poster")
                let series_poster_thumb = resultSet.string(forColumn: "series_poster_thumb")
                let dict : NSDictionary = [
                    "id" : id as Any,
                    "series_name" : series_name as Any,
                    "series_cover" : series_cover as Any,
                    "series_cover_thumb" : series_cover_thumb as Any,
                    "series_poster" : series_poster as Any,
                    "series_poster_thumb" : series_poster_thumb as Any]
                AllSeriesArray.add(dict)
            }
        }
        sharedInstance.database!.close()
        return AllSeriesArray
    }
    
    //3.Channels Favourites
    func InsertChannelsQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let insertquy = sharedInstance.database!.executeUpdate("INSERT INTO Favourite_Channel (cid, channel_title, channel_thumbnail) VALUES (?, ?, ?)", withArgumentsIn: [modalObj.cid as Any, modalObj.channel_title as Any, modalObj.channel_thumbnail as Any])
        sharedInstance.database!.close()
        return insertquy
    }
    func SingleChannelsQueryData(_ modalObj: Modal) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Channel WHERE cid=?", withArgumentsIn: [modalObj.cid as Any])
        let ChannelsInfoArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let modalObj : Modal = Modal()
                modalObj.cid = resultSet.string(forColumn: "cid")
                ChannelsInfoArray.add(modalObj)
            }
        }
        sharedInstance.database!.close()
        return ChannelsInfoArray
    }
    func DeleteChannelsQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM Favourite_Channel WHERE cid=?", withArgumentsIn: [modalObj.cid as Any])
        sharedInstance.database!.close()
        return isDeleted
    }
    func getAllChannelsQueryData() -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM Favourite_Channel", withArgumentsIn: [])
        let AllChannelsArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                /*let modalObj : Modal = Modal()
                modalObj.cid = resultSet.string(forColumn: "cid")
                modalObj.channel_title = resultSet.string(forColumn: "channel_title")
                modalObj.channel_thumbnail = resultSet.string(forColumn: "channel_thumbnail")
                AllChannelsArray.add(modalObj)*/
                
                let id = resultSet.string(forColumn: "cid")
                let channel_title = resultSet.string(forColumn: "channel_title")
                let channel_thumbnail = resultSet.string(forColumn: "channel_thumbnail")
                let dict : NSDictionary = [
                    "id" : id as Any,
                    "channel_title" : channel_title as Any,
                    "channel_thumbnail" : channel_thumbnail as Any]
                AllChannelsArray.add(dict)
            }
        }
        sharedInstance.database!.close()
        return AllChannelsArray
    }
    
    
    //4.Recently Viewed
    func InsertRecentlyViewedQueryData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let insertquy = sharedInstance.database!.executeUpdate("INSERT INTO RecentlyViewed (rid, title, cover_image, type) VALUES (?, ?, ?, ?)", withArgumentsIn: [modalObj.rid as Any, modalObj.title as Any, modalObj.cover_image as Any, modalObj.type as Any])
        sharedInstance.database!.close()
        return insertquy
    }
    func SingleRecentlyViewedQueryData(_ modalObj: Modal) -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM RecentlyViewed WHERE rid=?", withArgumentsIn: [modalObj.rid as Any])
        let RecentlyViewedArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let modalObj : Modal = Modal()
                modalObj.rid = resultSet.string(forColumn: "rid")
                RecentlyViewedArray.add(modalObj)
            }
        }
        sharedInstance.database!.close()
        return RecentlyViewedArray
    }
    func getAllRecentlyViewedQueryData() -> NSMutableArray
    {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM RecentlyViewed", withArgumentsIn: [])
        let AllRecentlyViewedArray : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                /*let modalObj : Modal = Modal()
                 modalObj.cid = resultSet.string(forColumn: "cid")
                 modalObj.channel_title = resultSet.string(forColumn: "channel_title")
                 modalObj.channel_thumbnail = resultSet.string(forColumn: "channel_thumbnail")
                 AllChannelsArray.add(modalObj)*/
                
                let id = resultSet.string(forColumn: "rid")
                let title = resultSet.string(forColumn: "title")
                let cover_image = resultSet.string(forColumn: "cover_image")
                let type = resultSet.string(forColumn: "type")
                let dict : NSDictionary = [
                    "id" : id as Any,
                    "title" : title as Any,
                    "cover_image" : cover_image as Any,
                    "type" : type as Any]
                AllRecentlyViewedArray.add(dict)
            }
        }
        sharedInstance.database!.close()
        return AllRecentlyViewedArray
    }
    
    
    
    
    
    /*func updateStudentData(_ modalObj: Modal) -> Bool
    {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE student_info SET Name=?, Marks=? WHERE RollNo=?", withArgumentsIn: [modalObj.Name, modalObj.Marks, modalObj.RollNo])
        sharedInstance.database!.close()
        return isUpdated
    }*/
}
