//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoAnnotated
import Result
import DoNotShipThis
import TooLegit

class ViewController: UIViewController {

    @IBOutlet var loadButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var canvadocsPresenter: CanvadocsPDFDocumentPresenter!
    var preSubmissionPresenter: PreSubmissionPDFDocumentPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
    }

    @IBAction func loadButtonTapped(_ sender: UIButton) {
        loadButton.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        loadPreSubmissionFlowDocument()
    }

    func loadLocalCanvadocsDocument() {
        let file = Bundle.main.url(forResource: "file_firstpage", withExtension: "pdf")!
        let annots = Bundle.main.url(forResource: "annotations", withExtension: "xfdf")!

        canvadocsPresenter = CanvadocsPDFDocumentPresenter(localPDFURL: file, localXFDFURL: annots)
        let vc = canvadocsPresenter.getPDFViewController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }

    func loadRemoteCanvadocsDocument() {
//        let sessionURL = URL(string: "https://canvadocs-edge.insops.net/1/sessions/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjIjoxNDQ2MjE1Nzc3MzkxLCJkIjoiOHlXLTJMMmQwVm1ZZEg5MWpCZ2F2X2xQdDlPN21WIiwiZSI6MTQ0NjgyMDU3NywiYSI6eyJjIjoiY2FudmFkb2NzX2FkbWluIiwicCI6InJlYWR3cml0ZSIsInUiOiJjYW52YWRvY3NfYWRtaW4iLCJuIjoiQ2FudmFkb2NzIFVzZXIiLCJyIjoiQWRtaW4ifSwiaWF0IjoxNDQ2MjE1Nzc3fQ.L7Q4Mxw9eQ7HP_a7_4QRCfiX8zcBoqNDAo_pvh_e0lM")!
//
//        DocumentPresenter.loadPDFViewController(sessionURL) { (viewController, error) in
//            self.activityIndicator.stopAnimating()
//            self.activityIndicator.hidden = true
//            self.loadButton.hidden = false
//
//            if let _ = error {
//                let alert = UIAlertController(title: "Error Fetching PDF", message: nil, preferredStyle: .Alert)
//                self.presentViewController(alert, animated: true, completion: nil)
//                return
//            }
//
//            if let viewController = viewController {
//                self.presentViewController(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
//            }
//        }
    }

    func loadPreSubmissionFlowDocument() {
        func pdfPath() -> String {
            let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return (pathToDocumentsFolder as NSString).appendingPathComponent("/file_firstpage.pdf")
        }

        let theFileManager = FileManager.default

        if theFileManager.fileExists(atPath: pdfPath()) {
            print("File Found!")
        }
        else {
            // Copy the file from the Bundle and write it to the Device:
            let pathToBundledPDF = Bundle.main.path(forResource: "file_firstpage", ofType: "pdf")
            let pathToDevice = pdfPath()

            // Here is where I get the error:
            let _ = try? theFileManager.copyItem(atPath: pathToBundledPDF!, toPath: pathToDevice)
        }

        let pdfURL = URL(fileURLWithPath: pdfPath())

        preSubmissionPresenter = PreSubmissionPDFDocumentPresenter(documentURL: pdfURL, session: Session.nas)
        let vc = preSubmissionPresenter.getPDFViewController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}
