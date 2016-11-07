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
    
    

import Foundation

extension Quiz {
    var timed: Bool {
        switch timeLimit {
        case .Minutes( _):
            return true
        default:
            return false
        }
    }
}

class QuizSubmissionTimerController: NSObject {
    
    let quiz: Quiz
    let timedQuizSubmissionService: TimedQuizSubmissionService
    var submission: Submission?
    
    private (set) var timerTime = 0
    var timerTick: (currentTime: Int)->() = { _ in }
    var timeExpired: ()->() = {}
    
    private var timer: NSTimer?
    private var timeSyncTimer: NSTimer?
    
    init(quiz: Quiz, timedQuizSubmissionService: TimedQuizSubmissionService) {
        self.quiz = quiz
        self.timedQuizSubmissionService = timedQuizSubmissionService
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func startSubmission(submission: Submission) {
        self.submission = submission
        
        syncStartingTime()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QuizSubmissionTimerController.applicationBecameActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        startTimers()
    }
    
    func stopTimedSubmission() {
        invalidateTimers()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationBecameActive() {
        syncStartingTime()
        syncTimeWithServer()
        
        invalidateTimers()
        startTimers()
    }
    
    private func startTimers() {
        timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(QuizSubmissionTimerController.updateTimer), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
        timeSyncTimer = NSTimer(timeInterval: 30.0, target: self, selector: #selector(QuizSubmissionTimerController.syncTimeWithServer), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timeSyncTimer!, forMode: NSRunLoopCommonModes)
    }
    
    private func invalidateTimers() {
        timer?.invalidate()
        timer = nil
        
        timeSyncTimer?.invalidate()
        timeSyncTimer = nil
    }
    
    private func syncStartingTime() {
        if quiz.timed {
            if let submission = submission {
                var secondsTimeLimit = 0
                switch quiz.timeLimit {
                case .Minutes(let minutes):
                    secondsTimeLimit = minutes * 60
                default: break
                }
                
                let startTime = submission.dateStarted!
                let currentTime = NSDate()
                let diff = currentTime.timeIntervalSinceDate(startTime)
                timerTime = secondsTimeLimit - Int(diff)
            }
        } else {
            if let submission = submission, startTime = submission.dateStarted {
                let currentTime = NSDate()
                let diff = currentTime.timeIntervalSinceDate(startTime)
                timerTime = Int(diff)
            }
        }
    }
    
    func updateTimer() {
        if quiz.timed {
            timerTime -= 1
        } else {
            timerTime += 1
        }
        
        timerTick(currentTime: timerTime)
        
        if timerTime <= 0 && quiz.timed {
            stopTimedSubmission()
            timeExpired()
        }
    }
    
    func syncTimeWithServer() {
        if quiz.timed {
            timedQuizSubmissionService.getTimeRemaining { [weak self] result in
                if let secondsLeft = result.value {
                    if let me = self {
                        me.timerTime = secondsLeft
                    }
                }
            }
        }
    }
}
