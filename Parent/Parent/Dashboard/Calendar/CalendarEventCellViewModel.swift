//
//  CalendarEventCellViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 1/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import SoPersistent
import CalendarKit

struct CalendarEventCellViewModel: TableViewCellViewModel {
    static var subtitleDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()

    static let reuseIdentifier = "CalendarEventCell"
    static let nibName = "CalendarEventCell"

    let name: String
    let subtitle: String
    let image: UIImage?
    let submittedText: String
    let submittedColor: UIColor
    let submittedImage: UIImage?
    let highlightColor: UIColor

    let calendarEvent: CalendarEvent

    init(calendarEvent: CalendarEvent, courseName: String?, highlightColor: UIColor) {
        self.calendarEvent = calendarEvent
        name = calendarEvent.title ?? ""
        subtitle = courseName ?? ""
        image = calendarEvent.type.image()
        submittedText = calendarEvent.submittedText
        submittedColor = calendarEvent.submittedColor
        submittedImage = calendarEvent.submittedImage
        self.highlightColor = highlightColor
    }
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 76
        tableView.registerNib(UINib(nibName: "CalendarEventCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "CalendarEventCellViewModel")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("CalendarEventCellViewModel", forIndexPath: indexPath) as? CalendarEventCell else {
            fatalError("Incorrect Cell Type Found Expected: CalendarEventTableViewCell")
        }

        cell.highlightColor = highlightColor
        cell.titleLabel.text = name
        cell.courseNameLabel.text = subtitle
        cell.typeImageView.tintColor = UIColor.whiteColor()
        cell.typeImageView.backgroundColor = submittedColor
        cell.statusLabel.text = submittedText
        cell.statusLabel.backgroundColor = submittedColor

        let imageSize = CGSize(width: CalendarEventCell.iconImageDiameter-CalendarEventCell.iconSubtrator, height: CalendarEventCell.iconImageDiameter-CalendarEventCell.iconSubtrator)
        let smallImage = submittedImage?.imageScaledToSize(imageSize) ?? image?.imageScaledToSize(imageSize)
        cell.typeImageView.contentMode = .Center
        cell.typeImageView.image = smallImage?.imageWithRenderingMode(.AlwaysTemplate)

        cell.titleLabel.accessibilityIdentifier = "event_title_\(indexPath.section)_\(indexPath.row)"
        cell.courseNameLabel.accessibilityIdentifier = "event_course_\(indexPath.section)_\(indexPath.row)"
        cell.typeImageView.accessibilityIdentifier = "event_icon_\(indexPath.section)_\(indexPath.row)"
        cell.statusLabel.accessibilityIdentifier = "event_status_\(indexPath.section)_\(indexPath.row)"

        return cell
    }
    
}

extension EventType {
    func image()->UIImage? {
        switch(self) {
        case .Assignment:
            return UIImage(named: "icon_assignment_fill")
        case .Quiz:
            return UIImage(named: "icon_quiz_fill")
        case .Discussion:
            return UIImage(named: "icon_discussion_fill")
        case .CalendarEvent:
            return UIImage(named: "icon_calendar_event_fill")
        case .Error:
            return UIImage(named: "icon_assignment_fill")
        }
    }
}