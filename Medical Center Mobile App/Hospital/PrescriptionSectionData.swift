//
//  PrescriptionSectionData.swift
//  Hospital
//
//  Created by Simone Montalto on 23/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class PrescriptionSectionData {
    static var prescriptionList: [TableViewSection]? = nil
    static var rawPrescriptionList = [Prescription]()
    
    static func getData(refreshData: Bool) -> [TableViewSection] {
        if prescriptionList == nil || refreshData {
            
            rawPrescriptionList.removeAll()
            getPrescriptionData()
            var todayList = [Prescription]()
            var nextDaysList = [Prescription]()
            
            for prescription in rawPrescriptionList {
                let prescriptionDate = prescription.date.components(separatedBy: "-")
                if let prescriptionDay = Int(prescriptionDate[2]) {
                    if let prescriptionMonth = Int(prescriptionDate[1]) {
                        if let prescriptionYear = Int(prescriptionDate[0]) {
                            let date = Date()
                            let calendar = Calendar.current
                            
                            let day = calendar.component(.day, from: date)
                            let month = calendar.component(.month, from: date)
                            let year = calendar.component(.year, from: date)
                            
                            if day == prescriptionDay && month == prescriptionMonth && year == prescriptionYear {
                                todayList.append(prescription)
                            } else if (month < prescriptionMonth && year <= prescriptionYear) || (day < prescriptionDay && month == prescriptionMonth && year == prescriptionYear) {
                                nextDaysList.append(prescription)
                            }
                        }
                    }
                }
            }
            
            let todaySection = TableViewSection(title: "Today", objects: todayList)
            let nextDaySection = TableViewSection(title: "Next Days", objects: nextDaysList)
            prescriptionList = [TableViewSection]()
            prescriptionList?.append(todaySection)
            prescriptionList?.append(nextDaySection)
            return prescriptionList!
        } else {
            
            return prescriptionList!
        }
    }
    
    static func getPrescriptionData() {
        if let path = Bundle.main.path(forResource: "json/prescriptionList", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    static func parse(json: JSON) {
        for examination in json.arrayValue {
            let prescription = Prescription(name: examination["name"].stringValue, date: examination["date"].stringValue, hour: examination["hour"].stringValue)
            rawPrescriptionList.append(prescription)
        }
    }
}
