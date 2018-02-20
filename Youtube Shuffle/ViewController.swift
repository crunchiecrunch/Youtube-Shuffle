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
import Darwin

class ViewController: UIViewController {
    let key = "AIzaSyBEzi61Ipzek8tYPwAYyLz8HGlQ-SW0j2A"
    @IBOutlet weak var webView: WKWebView!
    var items = [Item]()
    var isDone = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://youtube.com/")!)
        webView?.load(request)
    }
    
    @IBAction func shuffle(_ sender: Any) {
        guard isDone else { return }
        if let webViewUrl = webView.url{
            getChannelId(url: webViewUrl, completionHandler: { channelId in
                self.isDone = false
                self.items = [Item]()
                self.getData(channelId: channelId!, pageToken: nil)
            })
        }

    }

    func getData(channelId: String, pageToken: String?){
        var parameters = ["channelId": channelId, "part":"id", "key":key,"maxResults":"50"]
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
                    self.getData(channelId: channelId, pageToken: nextPageToken)
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
        isDone = true
        print(self.items.count)
        if self.items.count > 0 {
            let randomVideo = Int(arc4random_uniform(UInt32(self.items.count)))
            if let id = items[randomVideo].id, let videoId = id.videoId {
                let request = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=" + videoId)!)
                webView?.load(request)
            }
        }
    }
    
    func getChannelId(url: URL, completionHandler: @escaping ((_ channelId: String?)->())){
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let range = url.path.range(of: "channel/") else {
            
            //if no channel id exists in url, look up the user name
            guard let range = url.path.range(of: "user/") else { return }
            let parameters = ["forUsername": String(url.path[range.upperBound...]), "part":"id", "key":key]
            let decoder = JSONDecoder()
            Alamofire.request("https://www.googleapis.com/youtube/v3/channels", method: .get, parameters: parameters).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<ChannelData>) in
                switch response.result {
                case .success:
                    let channelData: ChannelData = response.result.value!
                    completionHandler(channelData.items?[0].id)
                case .failure(let error):
                    print(error)
                }
            }
            return
            
        }
        completionHandler(String(url.path[range.upperBound...]))
    }
    
}

