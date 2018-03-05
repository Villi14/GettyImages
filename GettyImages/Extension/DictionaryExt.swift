//
//  DictionaryExt.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/1/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

extension Dictionary {
    func stringFromHttpParameters() -> String {
        
        var parametersString = ""
        for (key, value) in self {
            if let key = key as? String {
                parametersString = parametersString + key + "=" + "\(value)" + "&"
            }
        }
        let beforeEndIndex = parametersString.index(before: parametersString.endIndex)
        parametersString = String(parametersString[..<beforeEndIndex])
        return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
