//
//  NetworkController.swift
//  AgoraDemo
//
//  Created by Rickie on 9/13/19.
//  Copyright © 2019 Rickie. All rights reserved.
//

import Foundation

class NetworkController
{
    static var shared = NetworkController()
    
    private init() { }
    
    func decode(_ data: Data?) -> KeyData? {
        var keyData : KeyData? = nil
        let decoder = JSONDecoder()
        do {
            keyData = try decoder.decode(KeyData.self, from: data!)
        } catch {
            print(error)
        }
        return keyData
    }
    
    func fetch(_ url: URL, withCompletion completion: @escaping (KeyData?) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral) // no cache session
        let task = session.dataTask(with: url, completionHandler: { [unowned self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(nil)
                return
            }
            let config = self.decode(data)
            completion(config)
        })
        task.resume()
    }
    
    func makeDate(_ str : String?) -> Date? {
        guard let str = str else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy h:m a zzz"
        let date = dateFormatter.date(from:str)
        return date
    }

}
