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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKConversationStateUnread = 1,
    CKConversationStateRead,
    CKConversationStateArchived,
} CKConversationState;


//   Sample API Object
// ---------------------
//{
//    "id": 2,
//    "workflow_state": "unread",
//    "last_message": "sure thing, here's the file",
//    "last_message_at": "2011-09-02T12:00:00Z",
//    "message_count": 2,
//    "subscribed": true,
//    "private": true,
//    "label": null,
//    "properties": ["attachments"],
//    "audience": [2],
//    "audience_contexts": {"courses": {"1": ["StudentEnrollment"]}, "groups": {}},
//    "avatar_url": "https://canvas.instructure.com/images/messages/avatar-group-50.png",
//    "participants": [{"id": 1, "name": "Joe TA"}, {"id": 2, "name": "Jane Teacher"}]
//}


@interface CKConversation : CKModelObject

@property (assign) uint64_t ident;
@property (assign) CKConversationState state;
@property (copy) NSString *lastMessagePreview;
@property (copy) NSDate *lastMessageDate;
@property (assign) NSUInteger messageCount;
@property (assign) BOOL userIsSubscribed;
@property (assign) BOOL isPrivate;
@property (copy) NSString *label;
@property (assign) BOOL hasAttachments;      // From 'properties' in JSON
@property (assign) BOOL userIsLastAuthor;    // From 'properties' in JSON
@property (assign) BOOL hasMediaAttachments; // From 'properties' in JSON
@property (copy) NSArray *audienceIDs;  // NSArray (NSNumber(int))
@property (copy) NSDictionary *audienceContexts; // See JSON example above
@property (copy) NSURL *avatarURL;
@property (copy) NSArray *participants; // NSArray (CKConversationRecipient), includes self

// The following are only populated after calling -[CKCanvasAPI getDetailedConversationForConversation...]

@property (copy) NSArray *relatedSubmissions; // NSArray (CKConversationRelatedSubmission)
@property (copy) NSArray *messages; // NSArray (CKConversationMessage), must be populated separately
// The `participants` ivar is also more detailed after calling the above method

- (id)initWithInfo:(NSDictionary *)info;
- (void)updateWithConversation:(CKConversation *)conversation;
- (void)updateWithNewMessagesFromConversation:(CKConversation *)conversation;

- (NSArray *)audienceNames;
- (NSArray *)audience;     // NSArray (CKConversationRecipient), ordered, w/o self.

@end
