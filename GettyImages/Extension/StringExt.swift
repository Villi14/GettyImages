//
//  StringExt.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/3/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

