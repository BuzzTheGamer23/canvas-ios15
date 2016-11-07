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
import MediaKit
import AVFoundation

enum MediaTest: String {
    case RecordAudio = "Record Audio Test"
    case PermissionDenied = "Record Permission Denied"
    case RequestsPermission = "Request Recording Permission"
}

class DeniedLOL: NSObject, AudioRecorderPermissionDelegate {
    var permission = AVAudioSessionRecordPermission.Undetermined
    
    func requestRecordPermission(response: PermissionBlock) {
        permission = .Denied
        response(false)
    }
    
    func recordPermission() -> AVAudioSessionRecordPermission {
        return permission
    }
}

class OkaySure: NSObject, AudioRecorderPermissionDelegate {
    var permission = AVAudioSessionRecordPermission.Undetermined
    
    func requestRecordPermission(response: PermissionBlock) {
        permission = .Granted
        response(true)
    }
    
    func recordPermission() -> AVAudioSessionRecordPermission {
        return permission
    }
}

class ViewController: UITableViewController {
    let tests: [MediaTest] = [.RecordAudio, .PermissionDenied, .RequestsPermission]

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MediaTestCell", forIndexPath: indexPath)
        cell.textLabel?.text = tests[indexPath.row].rawValue
        return cell
    }
    
    func showAudioRecorderWithDelegate(delegate: AudioRecorderPermissionDelegate, forRowAtIndexPath indexPath: NSIndexPath) {
        let audio = AudioRecorderViewController.presentFromViewController(self, completeButtonTitle: "So Done!", permissionDelegate:  delegate)
        
        audio.cancelButtonTapped = { [weak self] in
            self?.dismissViewControllerAnimated(true) {
                let alert = UIAlertController(title: "No worries, Mate.", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Crikey!", style: .Default, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            self?.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        audio.didFinishRecordingAudioFile = { [weak self] file in
            // clean up
            do { try NSFileManager.defaultManager().removeItemAtURL(file) } catch {}
            
            self?.dismissViewControllerAnimated(true) {
                let alert = UIAlertController(title: "Good on ya, Mate!", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Right!", style: .Default, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            self?.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    var denied = DeniedLOL()
    
    var okaySure = OkaySure()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tests[indexPath.row] {
        case .RecordAudio:
            showAudioRecorderWithDelegate(AVAudioSession.sharedInstance(), forRowAtIndexPath: indexPath)
            
        case .PermissionDenied:
            denied = DeniedLOL()
            showAudioRecorderWithDelegate(denied, forRowAtIndexPath: indexPath)
            
        case .RequestsPermission:
            okaySure = OkaySure() // so you can do it over and over and over and over...
            showAudioRecorderWithDelegate(okaySure, forRowAtIndexPath: indexPath)
        }
    }
}

