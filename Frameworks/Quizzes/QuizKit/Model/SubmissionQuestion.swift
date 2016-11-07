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
import SoLazy

struct SubmissionQuestion {
    init(question: Question, flagged: Bool, answer: SubmissionAnswer) {
        self.question = question
        self.flagged = flagged
        self.answer = answer
    }
    
    let question: Question
    let flagged: Bool
    let answer: SubmissionAnswer
    
    
    func selectAnswer(answer: SubmissionAnswer) -> SubmissionQuestion {
        return SubmissionQuestion(question: question, flagged: flagged, answer: answer)
    }
    
    func toggleFlag() -> SubmissionQuestion {
        return SubmissionQuestion(question: question, flagged: !flagged, answer: answer)
    }
    
    func shuffleAnswers() -> SubmissionQuestion {
        let newQuestion = Question(id: question.id, position: question.position, name: question.name, text: question.text, kind: question.kind, answers: question.answers.shuffle(), matches: question.matches)
        return SubmissionQuestion(question: newQuestion, flagged: flagged, answer: answer)
    }
}

// MARK: JSON

extension SubmissionQuestion: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> SubmissionQuestion? {
        if let json = json as? [String: AnyObject] {
            let flagged = json["flagged"] as? Bool ?? false
            
            if let question = Question.fromJSON(json), answerJSON: AnyObject = json["answer"] {
                var answer: SubmissionAnswer = .Unanswered
                switch question.kind {
                    case .TextOnly:
                        answer = .NA
                    case .TrueFalse, .MultipleChoice:
                        if let id = idString(answerJSON) {
                            answer = .ID(id)
                        }
                    case .MultipleAnswers:
                        if let ids = answerJSON as? [AnyObject] {
                            let newIDs: [String] = decodeArray(ids)
                            answer = .IDs(newIDs)
                    }
                    case .Essay, .ShortAnswer:
                        if let text = answerJSON as? String {
                            answer = .Text(text)
                        }
                    case .Numerical:
                        if let numberStr = answerJSON as? String {
                            answer = .Text(numberStr)
                        } else if let number = answerJSON as? Double {
                            answer = .Text(String(format: "%f", number))
                        }
                    case .Matching:
                        if let answers = answerJSON as? [AnyObject] {
                            var answerMatchMap: [String: String] = [:]
                            for obj in answers {
                                if let dict = obj as? [String:AnyObject] {
                                    if let answerID = idString(dict["answer_id"]), let matchID = idString(dict["match_id"]) {
                                        answerMatchMap[answerID] = matchID
                                    }
                                }
                            }
                            if answerMatchMap.keys.count > 0 {
                                answer = .Matches(answerMatchMap)
                            }
                        }
                    default:
                        answer = .Unanswered
                }
                
                return SubmissionQuestion(question: question, flagged: flagged, answer: answer)
            }
        }
        
        return nil
    }
}

