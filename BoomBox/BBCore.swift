//
//  BBCore.swift
//  BoomBox
//
//  Created by Ronan Furuta on 8/3/23.
//

import Foundation
import NaturalLanguage

public class BBCore {
    let packsURL = URL(filePath: "Users/\(NSUserName())/Library/Application Support/boomboxstable/db/packs")
    public var packs: [String: BBPack] = [:]
    public var sounds: [String: BBSound] = [:]
    public var tags: [String: [String]] = [:]
    
    //public var tagsList: [BBTag] = []
    public init() {
       
    }
    public func loadPacks(_ rootURL: URL) {
        print(NSUserName())
        do {
            print(packsURL)
            let data = try String(contentsOf: rootURL.appending(path: "db/packs"), encoding: .utf8).data(using: .utf8)!
            print(data.count, "charachters loaded")
            let res = try JSONDecoder().decode([String: BBPack].self, from: data)
            print(res.count, "packs laoded")
            self.packs = res
            res.values.forEach({pack in
                self.sounds.merge(pack.sounds) { a, b in
                    return a
                }
                self.tags.merge(pack.tagsSoundsIndex) { old, new in
                    return new
                }
                
            })
            print(sounds.count, "sounds loaded")
            self.analyzeTags()
        } catch {
            print(error)
        }
        
    }
    public func analyzeTags() {
        /*let tagger = NLTagger(tagSchemes: [.lexicalClass])
        self.tags.keys.forEach({tag in
            let text = tag
            tagger.string = text
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
                if let tag = tag {
                    print("\(text[tokenRange]): \(tag.rawValue)")
                }
                return true
            }
        })*/
        var tagCases = ""
        self.tags.keys.forEach({tag in
            tagCases.append("\n case \(tag)")
           // self.tagsList.append(BBTag(id: tag))
        })
        //print(tagCases)
       
    }
    public func search(_ searchString: String, _ searchTags: [BBTag]) async -> [String] {
        print("searching", searchString, searchTags)
        if (searchString.isEmpty && searchTags.isEmpty) {
            return Array(self.sounds.keys)
        }
      
       
        let searchString = searchString.lowercased()
        var result: [String] = []
        
        result = sounds.filter { sound in
            let searcStrings = sound.value.searchString.components(separatedBy: ",")
            print(sound.value.searchString)
               
           // var result = sound.value.searchString.contains(searchString)
            var result: Int = 0
            searchTags.forEach({tag in
                if (searcStrings.contains(tag.id)) {
                    result += 1
                }
            })
           
           /* for string in searcStrings {
             
               /* let distance = sentenceEmbedding.distance(between: searchString, and: string)
                print(string, distance)
                if (distance < 1.1) {
                    
                    result = true
                    break
                }*/
                if (string.cont)
            } */
             
              
            if (searchTags.isEmpty) {
                return sound.value.searchString.contains(searchString)
            } else if (searchString.isEmpty) {
                return result == searchTags.count
            } else {
                return result == searchTags.count && sound.value.searchString.contains(searchString)
            }
           
        }.map {item in
            return item.key
        }
        return result
    }
}
