//
//  Date+Ext.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}
