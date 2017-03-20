//
//  File.swift
//  Hospital
//
//  Created by Simone Montalto on 19/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import Foundation

class MedicalExaminationSectionData {
    
    static var medicalExaminationList: [TableViewSection]? = nil
    static var rawExaminationList = [ExaminationDetail]()
    
    static func getData(refreshData: Bool) -> [TableViewSection] {
        if medicalExaminationList == nil || refreshData {
            
            rawExaminationList.removeAll()
            getExaminationData()
            var todayList = [ExaminationDetail]()
            var nextDaysList = [ExaminationDetail]()
            
            for examination in rawExaminationList {
                let examinationDate = examination.date.components(separatedBy: "-")
                if let examinationDay = Int(examinationDate[2]) {
                    if let examinationMonth = Int(examinationDate[1]) {
                        if let examinationYear = Int(examinationDate[0]) {
                            let date = Date()
                            let calendar = Calendar.current
                            
                            let day = calendar.component(.day, from: date)
                            let month = calendar.component(.month, from: date)
                            let year = calendar.component(.year, from: date)
                            
                            if day == examinationDay && month == examinationMonth && year == examinationYear {
                                todayList.append(examination)
                            } else if (month < examinationMonth && year <= examinationYear) || (day < examinationDay && month == examinationMonth && year == examinationYear) {
                                nextDaysList.append(examination)
                            }
                        }
                    }
                }
            }
            
            let todaySection = TableViewSection(title: "Today", objects: todayList)
            let nextDaySection = TableViewSection(title: "Next Days", objects: nextDaysList)
            medicalExaminationList = [TableViewSection]()
            medicalExaminationList?.append(todaySection)
            medicalExaminationList?.append(nextDaySection)
            return medicalExaminationList!
        } else {

            return medicalExaminationList!
        }
    }
    
    static func getExaminationData() {
        if let path = Bundle.main.path(forResource: "json/examinationList", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) {
                let json = JSON(data: data)
                parse(json: json)
            }
        }
    }
    
    static func parse(json: JSON) {
        for examination in json.arrayValue {
            let examinationDetail = ExaminationDetail(name: examination["name"].stringValue, date: examination["date"].stringValue, hour: examination["hour"].stringValue, examinationDescription: examination["description"].stringValue, doctor: examination["doctor"].stringValue)
            rawExaminationList.append(examinationDetail)
        }
    }
    
}
