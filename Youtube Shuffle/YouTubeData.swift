//
//  YouTubeData.swift
//  Youtube Shuffle
//
//  Created by Luke Job on 1/02/18.
//  Copyright © 2018 Luke Job. All rights reserved.
//

import Foundation

struct YouTubeData: Codable {
    
    let nextPageToken: String?
    let items: [Item]?
}

struct Item: Codable {
    let id: Id?
    
    struct Id: Codable {
        let videoId: String?
    }
}

//channel

struct ChannelData: Codable {
    let items: [ChannelItem]?
}

struct ChannelItem: Codable {
    let id: String?
}
