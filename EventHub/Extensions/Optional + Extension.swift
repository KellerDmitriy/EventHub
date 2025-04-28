//
//  Optional + Extension.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 28.04.2025.
//

import Foundation


extension Optional where Wrapped == Date {
    static func compareAscending(_ lhs: Date?,_ rhs: Date?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?): return l < r
        case (nil, _?): return false
        case(_?, nil): return true
        case(nil, nil): return false
        }
    }
}
