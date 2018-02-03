//
//  DayButton.swift
//  ConstructionWorkResults
//
//  Created by okada on 2018/01/24.
//  Copyright © 2018年 okada. All rights reserved.
//

import UIKit

protocol DayButtonDelegate: class {
    func didSelect(_ dayButton: DayButton)
    func didDeselect(_ dayButton: DayButton)
}

class DayButton: UIButton {
    
    weak var delegate: DayButtonDelegate?
    
    var date = Date()
    
    @IBInspectable var row: Int = 0
    
    @IBInspectable var weekDay: Int = 1
    
    var weekDayType: WeekDay {
        return WeekDay(rawValue: weekDay)!
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                delegate?.didSelect(self)
            } else {
                delegate?.didDeselect(self)
            }
        }
    }
}
