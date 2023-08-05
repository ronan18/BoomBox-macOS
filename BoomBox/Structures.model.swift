//
//  Sound.model.swift
//  BoomBox
//
//  Created by Ronan Furuta on 8/3/23.
//

import Foundation
import CoreTransferable
import AVKit

public struct BBSound: Identifiable, Codable {
    public let id: String
    public let fileUri: String
    public let title: String
    public let packId: String
    public let cuePoints: [Double]
    public let ext: String
    public let tags: [String]
    public let searchString: String
   
    
    public var url: URL {
        return URL(filePath: "/Users/\(NSUserName())/Library/Application Support/boomboxstable/\(self.fileUri)")
    }

     public var duration: TimeInterval {
       
           /* let attributes =  try FileManager.default.attributesOfItem(atPath: url.path)
            print(attributes.keys)*/
           let asset = AVAsset(url: self.url)
      
       var duration: TimeInterval = asset.duration.seconds
        
            
           // self.durationStore = duration
            return duration
     
    }
    
    
}

public struct BBPack: Identifiable, Codable {
    public let id: String
    public let title: String
    public let previewSoundUri: String
    public let tagsSoundsIndex: [String: [String]]
    public let changelog: String?
    public let localPreviewSound: String
    public let imageUri: String
    public let totalSounds: Int
    public let description: String
    public let ts: Int
    public let version: Int
    public let zipUri: String
    public let localImage: String
    public let type: String
    public let sounds: [String: BBSound]
    public var imageURL: URL {
        return URL(filePath: "/Users/\(NSUserName())/Library/Application Support/boomboxstable/\(self.imageUri)")
    }
    
    
}
public struct BBTag: Identifiable {
   public var id: String
    public init(_ id: String) {
        self.id = id
    }
}

extension BBSound: Transferable {
    static public var transferRepresentation: some TransferRepresentation {
       // CodableRepresentation(contentType: .wav)
        //ProxyRepresentation(exporting: \.title)
        FileRepresentation(exportedContentType: .wav, exporting: {sound in
           // SentTransferredFile(sound.url)
            print("sound export", sound.title, sound.url)
            return SentTransferredFile(sound.url)
        })
    }
}
public extension TimeInterval {
     func timeCodeLength() -> String {
       
        let seconds = Int(self.rounded(.down))
         let frames: Double = (self - Double(seconds)) * 24
        return  "\(seconds):\(Int(frames))"
    }
}
