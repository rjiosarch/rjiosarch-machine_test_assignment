//
//  IpInfo.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import Foundation

struct IpInfo: Decodable {
    let city: String?
    let region: String?
    let country: String?
    let loc: String?
    let org: String?
    let timezone: String?
}

struct Ip_Response: Decodable {
    let ip: String
}
