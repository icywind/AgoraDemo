//
//  KeyCenter.swift
//  AgoraDemo
//
//  Created by Rickie on 9/11/19.
//  Copyright © 2019 Rickie. All rights reserved.
//

import Foundation

struct KeyCenter {
    static let AppId: String = "abd848cd5b4b4af78c7d7b93a2505425"
    
    // assign token to nil if you have not enabled app certificate
    static var Token: String? = "006abd848cd5b4b4af78c7d7b93a2505425IADA1jqFDyrOJVkuPAAAqw2m5M1H7GdRMggeixEPLoWRT+ShgdAAAAAAEACbEEiUzoB9XQEAAQDOgH1d"
    // Token expires on September 15, 2019 12:07 AM UTC

    static let ConfigURL : String = "https://fattag.com/agora.json"
    
    static func makeDate(str : String?) -> Date? {
        guard let str = str else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy h:m a zzz"
        let date = dateFormatter.date(from:str)
        return date
    }
}

struct KeyData : Codable {
    let token : String?
    let expires : String?
}
