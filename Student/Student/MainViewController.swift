//
//  MainViewController.swift
//  Student
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func goToDetail() {
        router.route(to: "/detail", from: self)
    }
}
