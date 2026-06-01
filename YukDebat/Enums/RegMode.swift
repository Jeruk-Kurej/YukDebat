//
//  RegMode.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Foundation

/// Defines whether a participant joins a sparring room individually or with a teammate.
enum RegMode: String, Codable {
    case solo = "SOLO"
    case team = "TEAM"
}
