//
//  ViewController.swift
//  Youtube Shuffle
//
//  Created by Luke Job on 31/01/18.
//  Copyright © 2018 Luke Job. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import CodableAlamofire

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let request = URLRequest(url: URL(string: "http://youtube.com/")!)
//        webView?.load(request)
    }
    
    @IBAction func shuffle(_ sender: Any) {
        self.items = [Item]()
        self.getData(pageToken: nil)
    }
    //UC1FsSaQlCGmCR_FwuhfRyeg - crunch
    //UClgMtOZ78-98bANHRSOyhCA
    func getData(pageToken: String?){
        var parameters = ["channelId": "UClgMtOZ78-98bANHRSOyhCA", "part":"id", "key":"AIzaSyBEzi61Ipzek8tYPwAYyLz8HGlQ-SW0j2A", "ios_bundle_id":"crunch.Youtube-Shuffle","maxResults":"50"]
        if let pageToken = pageToken{
            parameters["pageToken"] = pageToken
        }
        let decoder = JSONDecoder()
        Alamofire.request("https://www.googleapis.com/youtube/v3/search", method: .get, parameters: parameters).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<YouTubeData>) in
            switch response.result {
            case .success:
                let youTubeData: YouTubeData = response.result.value!
                self.items.append(contentsOf: youTubeData.items!)
                if let nextPageToken = youTubeData.nextPageToken{
                    self.getData(pageToken: nextPageToken)
                }
                else{
                    self.done()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func done(){
        
    }
    
}

