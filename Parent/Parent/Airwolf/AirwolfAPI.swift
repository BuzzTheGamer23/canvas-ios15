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
import CanvasCore

open class AirwolfAPI {
    // MARK: Parent calls
    open class func authenticateRequest(email: String, password: String) throws -> URLRequest {
        let url = RegionPicker.shared.apiURL
            .appendingPathComponent("authenticate")
        return try URLRequest(method: .POST, URL: url, parameters: ["username": email, "password": password], encoding: .json)
    }
    
    open class func authenticateAsCanvasObserver(_ domain: String, provider: String?) -> URLRequest {
        let url = RegionPicker.shared.apiURL
            .appendingPathComponent("canvas")
            .appendingPathComponent("authenticate")

        var parameters = ["domain": domain]
        if let provider = provider {
            parameters["authentication_provider"] = provider
        }
        
        return try! URLRequest(method: .GET, URL: url, parameters: parameters, encoding: .url)
    }

    open class func createAccountRequest(email: String, password: String, firstName: String, lastName: String) throws -> URLRequest {
        let url = RegionPicker.shared.apiURL
            .appendingPathComponent("newparent")
        return try URLRequest(method: .PUT, URL: url, parameters: ["parent": ["username": email, "password": password, "first_name": firstName, "last_name": lastName]], encoding: .json)
    }

    open class func sendPasswordResetEmailRequest(email: String) throws -> URLRequest {
        let url = RegionPicker.shared.apiURL
            .appendingPathComponent("send_password_reset/\(email)")
        return try URLRequest(method: .POST, URL: url, parameters: [:], encoding: .urlEncodedInURL)
    }

    open class func resetPasswordRequest(email: String, password: String, token: String) throws -> URLRequest {
        let url = RegionPicker.shared.apiURL
            .appendingPathComponent("reset_password")
        var request = try URLRequest(method: .POST, URL: url, parameters: ["username": email, "password": password], encoding: .json)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: Student calls
    open class func getStudentsRequest(_ session: Session, parentID: String) throws -> URLRequest {
        return try session.GET("/students/\(parentID)")
    }

    open class func addStudentRequest(_ session: Session, parentID: String, studentDomain: URL, authenticationProvider: String?) throws -> URLRequest {
        var parameters = ["student_domain": studentDomain.absoluteString]
        if let provider = authenticationProvider {
            parameters["authentication_provider"] = provider
        }
        return try session.GET("/add_student/\(parentID)", parameters: parameters, encoding: .urlEncodedInURL, authorized: true)
    }

    open class func checkDomainRequest(_ session: Session, parentID: String, studentDomain: URL) throws -> URLRequest {
        return try session.GET("/check_domain/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString], encoding: .urlEncodedInURL, authorized: true)
    }

    open class func deleteStudentRequest(_ session: Session, parentID: String, studentID: String) throws -> URLRequest {
        return try session.DELETE("/student/\(parentID)/\(studentID)")
    }
}
