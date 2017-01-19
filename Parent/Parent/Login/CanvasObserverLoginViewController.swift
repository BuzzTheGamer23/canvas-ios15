//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import SoPretty
import SoLazy
import ReactiveSwift
import Airwolf
import TooLegit
import Marshal

class CanvasObserverLoginViewController: WebLoginViewController, UIWebViewDelegate {
    let loginSuccess: (Session)->()
    
    init(domain: String, loginSuccess: @escaping (Session)->()) {
        self.loginSuccess = loginSuccess
        super.init(request: AirwolfAPI.authenticateAsCanvasObserver(domain), useBackButton: true, loginFailureMessage: NSLocalizedString("Only Canvas observers can authenticate in Canvas Parent.", comment: "Canvas Observer Auth Failed Message"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Just can't do it. sorry."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prompt = NSLocalizedString("Enter your Canvas Observer credentials", comment: "prompt for canvas observer login page")
        webView.delegate = self
    }
    
    var jsonBodyData: Data? {
        return webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('pre')[0].innerHTML")?.data(using: String.Encoding.utf8)
    }
    
    // MARK: UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.url else { return true }
        
        
        let commonResponses = handleCommonResponses(url)
        if commonResponses.failedLogin {
            return commonResponses.shouldStartLoad
        }
        
        guard url.path == "/canvas/tokenReady" else { return true }
        guard let host = request.url?.host, let baseURL = URL(string: "https://\(host)") else { return true }
        guard let token = url.queryItemForKey("token")?.value else { return true }
        guard let parentID = url.queryItemForKey("parent_id")?.value else { return true }
        
        let sessionUser = SessionUser(id: parentID, name: "")
        let session = Session(baseURL: baseURL, user: sessionUser, token: token)
        webView.isHidden = true
        loginSuccess(session)
        
        return true
    }
}
