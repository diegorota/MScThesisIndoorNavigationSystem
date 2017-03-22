//
//  POIData.swift
//  Hospital
//
//  Created by Simone Montalto on 22/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit

class POIData {
    
    static var POIList: [POIDetail]? = nil
    
    static func getData() -> [POIDetail] {
        if POIList == nil {
            POIList = [POIDetail]()
            getPOIData()
            return POIList!
        } else {
            return POIList!
        }
    }
    
    static func getPOIData() {
        if let path = Bundle.main.path(forResource: "json/POIList", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    static func parse(json: JSON) {
        for poi in json.arrayValue {
            let newPOI = POIDetail(ID: poi["ID"].stringValue, name: poi["name"].stringValue, hour: poi["hour"].stringValue, description: poi["description"].stringValue, manager: poi["manager"].stringValue, building: poi["building"].stringValue, coordinates: CGPoint(x: poi["x_coordinate"].intValue, y: poi["y_coordinate"].intValue))
            POIList?.append(newPOI)
        }
    }
    
}
