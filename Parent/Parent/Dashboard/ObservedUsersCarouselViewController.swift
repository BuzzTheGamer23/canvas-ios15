//
//  ObservedUsersCarouselViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import CoreData
import SoPersistent
import SoLazy
import ReactiveCocoa
import Kingfisher
import Airwolf

typealias StudentFetchedCollection = FetchedCollection<Student>

class ObserveesCarouselViewController: UIViewController {
    let collection: StudentFetchedCollection
    let syncProducer: Student.ModelPageSignalProducer
    var disposable: Disposable?
    
    var currentStudent: Student? {
        didSet {
            updateCarouselAccessibility()
            studentChanged(currentStudent)
        }
    }
    let carousel: iCarousel = iCarousel(frame: CGRectZero)
    
    var studentChanged: (Student?)->Void = { _ in }

    init(session: Session) throws {
        self.collection = try Student.observedStudentsCollection(session)
        self.syncProducer = try Student.observedStudentsSyncProducer(session)

        super.init(nibName: nil, bundle: nil)

        carousel.dataSource = self
        carousel.delegate = self
        carousel.centerItemWhenSelected = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.translatesAutoresizingMaskIntoConstraints = false
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.decelerationRate = 0.2
        self.view.addSubview(carousel)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": carousel]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": carousel]))

        reloadData()
        reloadCoverFlowType()
        collection.collectionUpdated = { [unowned self] updates in
            self.reloadCoverFlowType()
            self.carousel.reloadData()

            self.currentStudent = self.studentAtCarouselIndex(self.carousel.currentItemIndex)
        }
    }

    func reloadCoverFlowType() {
        carousel.type = numberOfItemsInCarousel(carousel) > 2 ? .Rotary : .CoverFlow
    }
    
    func reloadData() {
        disposable = syncProducer.start { [unowned self] event in
            switch event {
            case .Completed, .Interrupted, .Failed:
                self.reloadCoverFlowType()
                self.carousel.reloadData()
            default: break
            }
        }
    }
}

extension ObserveesCarouselViewController : iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return collection.numberOfItemsInSection(0)
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var itemView: UIImageView
        // TODO: Portrait itemSize = 65
        // Landscape = 40
        let itemSize: CGFloat = (UIDevice.currentDevice().orientation.isLandscape && UIDevice.currentDevice().userInterfaceIdiom == .Phone) ? 40 : 65
        
        //create new view if no view is available for recycling
        if view == nil {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:itemSize, height:itemSize))
            itemView.layer.cornerRadius = itemSize/2
            itemView.layer.borderColor = UIColor.whiteColor().CGColor
            itemView.layer.borderWidth = 2.0
            itemView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            itemView.clipsToBounds = true
        } else {
            itemView = view as! UIImageView;
        }

        itemView.isAccessibilityElement = true
        itemView.accessibilityIdentifier = "student_carousel_view_\(index)"

        let student = studentAtCarouselIndex(index)
        if let student = student, url = student.avatarURL {
            itemView.accessibilityLabel = student.name
            itemView.kf_setImageWithURL(url,
                placeholderImage: DefaultAvatarCoordinator.defaultAvatarForStudent(student),
                optionsInfo: [])
        }

        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch(option) {
        case .Spacing:
            if numberOfItemsInCarousel(carousel) <= 2 {
                return 1.0
            }

            let numberOfItems = CGFloat(numberOfItemsInCarousel(carousel))
            let maxWidth: CGFloat = 1.75
            let minWidth: CGFloat = 1.0
            let variance = maxWidth - minWidth
            let maxBreakNumber: CGFloat = 10.0
            let maxPercentage: CGFloat = min((numberOfItems/maxBreakNumber), 1.0)
            let value: CGFloat = maxWidth - (variance * maxPercentage)
            return value
        case .Wrap:
            return numberOfItemsInCarousel(carousel) > 2 ? 1.0 : 0.0
        case .Tilt:
            return 0.2
        case .FadeMin:
            return 0.1
        case .FadeMax:
            return 0.1
        case .FadeMinAlpha:
            return numberOfItemsInCarousel(carousel) > 3 ? 0.1 : 0.5
        default:
            return value
        }
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        guard collection.numberOfItemsInSection(0) > 0 else {
            return
        }

        currentStudent = studentAtCarouselIndex(carousel.currentItemIndex)
    }
    
    func studentAtCarouselIndex(index: Int) -> Student? {
        guard index >= 0 else { return nil }
        guard collection.numberOfItemsInSection(0) > index else { return nil }
        return collection[NSIndexPath(forRow: index, inSection: 0)]
    }

    func updateCarouselAccessibility() {
        var accessibilityElements: [AnyObject] = []
        for i in 0..<carousel.numberOfItems {
            guard let item = carousel.itemViewAtIndex(i) else { continue }

            if i < carousel.currentItemIndex {
                accessibilityElements.append(item)
                item.accessibilityTraits = UIAccessibilityTraitButton
            } else if i == carousel.currentItemIndex {
                accessibilityElements.insert(item, atIndex: 0)
                item.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitSelected
            } else {
                accessibilityElements.insert(item, atIndex: i - carousel.currentItemIndex)
                item.accessibilityTraits = UIAccessibilityTraitButton
            }
        }

        carousel.accessibilityElements = accessibilityElements
    }
}

