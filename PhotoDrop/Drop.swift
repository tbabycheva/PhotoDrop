//
//  Drop.swift
//  PhotoDrop
//
//  Created by Micah Bunting on 7/25/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

class Drop: CloudKitSyncable, HashableUsingAddress {
    var title: String
    var dropperUserId: CKRecordID
    var timestamp: Date
    var numberOfLikes: Int
    var location: CLLocationCoordinate2D
    var image: UIImage?
    var imageAsset: CKAsset?

    var hasLiked: Bool?
    var dropperUserName: String?
    
    var hasDetailDrop: Bool {
        return hasLiked != nil && image != nil && dropperUserName != nil
    }
    
    init(
        title: String,
        dropperUserId: CKRecordID,
        timestamp: Date,
        numberOfLikes: Int,
        location: CLLocationCoordinate2D,
        imageAsset: CKAsset? = nil,
        image: UIImage?
    ) {
        self.title = title
        self.dropperUserId = dropperUserId
        self.timestamp = timestamp
        self.numberOfLikes = numberOfLikes
        self.location = location
        self.imageAsset = imageAsset
        self.image = image
    }
    
    /* CloudKitSyncable */
    var record: CKRecord?
    
    static let recordType = "Drop"
    
    static let database: CKDatabase = CKContainer.default().publicCloudDatabase
    
    private struct Keys {
        static let title = "title"
        static let dropperUserId = "dropperUserId"
        static let timestamp = "timestamp"
        static let numberOfLikes = "numberOfLikes"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let image = "image"
    }
    
    var recordDictionary: [String: CKRecordValue] {
        if imageAsset == nil {
            getImageAsset: do {
                guard let image = image else { break getImageAsset }
                let data = UIImagePNGRepresentation(image)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".png")
                guard let tempURL = url else { break getImageAsset }
                try data?.write(to: tempURL, options: [])
                imageAsset = CKAsset(fileURL: tempURL)
            } catch {
                print("error writing data", error)
            }
        }

        var dictionary = [
            Drop.Keys.title: title as CKRecordValue,
            Drop.Keys.dropperUserId: CKReference(recordID: dropperUserId, action: CKReferenceAction.none),
            Drop.Keys.timestamp: timestamp as CKRecordValue,
            Drop.Keys.numberOfLikes: numberOfLikes as CKRecordValue,
            Drop.Keys.latitude: location.latitude as CKRecordValue,
            Drop.Keys.longitude: location.longitude as CKRecordValue,
        ]

        if let imageAsset = imageAsset {
            dictionary[Drop.Keys.image] = imageAsset
        }

        return dictionary
    }
    
    convenience required init?(record: CKRecord) {
        guard
            let title = record[Drop.Keys.title] as? String,
            let dropperUserId = record[Drop.Keys.dropperUserId] as? CKReference,
            let timestamp = record[Drop.Keys.timestamp] as? Date,
            let numberOfLikes = record[Drop.Keys.numberOfLikes] as? Int,
            let latitude = record[Drop.Keys.latitude] as? CLLocationDegrees,
            let longitude = record[Drop.Keys.longitude] as? CLLocationDegrees,
            
            let imageAsset = record[Drop.Keys.image] as? CKAsset,
            let data = NSData(contentsOf: imageAsset.fileURL),
            let image = UIImage(data: data as Data)
        
        else {
                return nil
        }
        self.init(
            title: title,
            dropperUserId: dropperUserId.recordID,
            timestamp: timestamp,
            numberOfLikes: numberOfLikes,
            location: CLLocationCoordinate2D(latitude:latitude, longitude:longitude),
            imageAsset: imageAsset,
            image: image 
        )
    }
}
