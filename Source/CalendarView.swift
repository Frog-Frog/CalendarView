//
//  CalenadarView.swift
//  ConstructionWorkResults
//
//  Created by okada on 2018/01/24.
//  Copyright © 2018年 okada. All rights reserved.
//

import UIKit

typealias YearMonth = (year: Int, month: Int)

enum SelectType {
    case none
    case single
    case multiple
}


protocol CalendarViewDataSource: class {
    func startYearMonth(in calendarView: CalendarView) -> YearMonth
}

protocol CalendarViewDelegate: class {
    func calendarView(_ calendarView: CalendarView, didSelect date: Date)
    
    func calendarView(_ calendarView: CalendarView, didDeselect date: Date)
}

extension CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelect date: Date) {}
    
    func calendarView(_ calendarView: CalendarView, didDeselect date: Date) {}
}

class CalendarView: UIView {
    @IBOutlet private var dayButtonCollection: [DayButton]!
    
    @IBOutlet private weak var daysView: UIView!
    
    weak var dataSource: CalendarViewDataSource? {
        didSet {
            if let yearMonth = dataSource?.startYearMonth(in: self),
                let date = Date.from(year: yearMonth.year, month: yearMonth.month, day: 1) {
                startDate = date
            } else {
                startDate = Date().firstOfMonth
            }
            
            reloadData()
        }
    }
    
    weak var delegate: CalendarViewDelegate?
    
    var selectType = SelectType.single
    
    var changeColorDays = [Date]()
    
    var changeColor = UIColor(hex: "FF8983")
    
    var todayColor = UIColor(hex: "3182D9")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        loadXib(className())
    }
}


// MARK: - IBAction
extension CalendarView {
    @IBAction func tappedPreviousMonthButton(_ sender: Any) {
        startDate = startDate.difference(month: -1)
        reloadData()
    }
    
    @IBAction func tappedNextMonthButton(_ sender: Any) {
        startDate = startDate.difference(month: 1)
        reloadData()
    }
    
    @IBAction func tappedDayButton(_ sender: DayButton) {
        sender.isSelected = !sender.isSelected
    }
}

// MARK: - Public
extension CalendarView {
    func reloadData() {
        dayButtonCollection.sort { (A, B) -> Bool in
            if A.row == B.row {
                //列が一緒なら曜日でソート
                return A.weekDay < B.weekDay
            }
            return A.row < B.row
        }
        
        reloadDays()
    }
    
    
    private func reloadDays() {
        
        daysView.subviews.forEach { if $0 is UIImageView { $0.removeFromSuperview()} }
        
        
        
        let weekDay = startDate.weekday.rawValue
        // weekDayは1スタートなので、1 - weekDayで週の始まる日曜日の日付を取得する。
        var setDate = startDate.difference(days: 1 - weekDay)
        
        // 表示開始日付を取得
        
        for button in dayButtonCollection {
            
            button.isUserInteractionEnabled = selectType == .none ? false : true
            
            button.delegate = self
            
            button.date = setDate
            
            let date = setDate.firstOfMonth
            button.isEnabled = date.isSameDate(startDate)
            
            if button.isEnabled && button.date.isSameDate(Date()) {
                layoutIfNeeded()
                
                let image = UIImage(named: "cv_button_today_hlt")?.withRenderingMode(.alwaysTemplate)
                let imageView = UIImageView(image: image)
                imageView.tintColor = todayColor
                imageView.frame = daysView.convert(button.frame, from: button.superview)
                daysView.addSubview(imageView)
                
            } else {
                switch button.weekDayType {
                case .sunday:
                    button.setTitleColor(UIColor(hex: "C93F45"), for: .normal)
                case .saturday:
                    button.setTitleColor(UIColor(hex: "2769B0"), for: .normal)
                default:
                    button.setTitleColor(UIColor(hex: "202020"), for: .normal)
                }
                
            }
            
            //色変更日付の場合ボタンの背景色変更する
            let count = changeColorDays.filter{ $0.isSameDate(setDate) }.count
            if button.isEnabled && count > 0{
                button.backgroundColor = changeColor
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(hex: "E8ECEE")
            }
            
            if button.isEnabled {
                button.setTitle("\(setDate.day)", for: .normal)
            } else {
                button.setTitle("", for: .normal)
            }
            
            setDate = setDate.difference(days: 1)
            
        }
    }
}


// MARK: - DayButtonDelegate
extension CalendarView: DayButtonDelegate {
    func didSelect(_ dayButton: DayButton) {
        delegate?.calendarView(self, didSelect: dayButton.date)
    }
    
    func didDeselect(_ dayButton: DayButton) {
        delegate?.calendarView(self, didDeselect: dayButton.date)
    }
}

