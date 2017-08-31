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
    
    

#import "CBIMessageParticipantsCell.h"
#import "CBIMessageParticipantsViewModel.h"
#import "EXTScope.h"
#import "NSArray_in_additions.h"
#import <CanvasKit1/CanvasKit1.h>
@import CanvasKit;
@import CanvasKeymaster;

@interface CBIMessageParticipantsCell ()
@property (weak, nonatomic) IBOutlet UIView *addRecipientsButton;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addParticipantsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addParticipantsButtonWidthConstraint;
@end

@implementation CBIMessageParticipantsCell

- (void)awakeFromNib
{
    self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    NSString *myUserID = [CKIClient currentClient].currentUser.id;
    
    [self.toLabel setText:NSLocalizedString(@"To:", nil)];
    
    RACSignal *existingParticipantsNames = [RACObserve(self, viewModel.model.participants) map:^id(NSArray *participants) {
        return [[participants.rac_sequence filter:^BOOL(CKIUser *user) {
            return ![user.id isEqualToString:myUserID];
        }] map:^id(CKIUser *user) {
            return user.name;
        }].array;
    }];
    
    RACSignal *pendingRecipientsNames = [RACObserve(self, viewModel.pendingRecipients) map:^id(NSArray *pending) {
        return [pending.rac_sequence map:^id(CKUser *user) {
            return user.name;
        }].array;
    }];

    UIFont *font = self.participantsLabel.font;
    RACSignal *participantStringSignal = [RACSignal combineLatest:@[existingParticipantsNames, pendingRecipientsNames, RACObserve(self, participantsLabel.bounds)] reduce:^id(NSArray *existing, NSArray *pending, NSValue *bounds) {
        NSMutableArray *all = [NSMutableArray array];
        if ([existing count]) {
            [all addObjectsFromArray:existing];
        }
        if ([pending count]) {
            [all addObjectsFromArray:pending];
        }
        
        return [all in_componentsJoinedByString:@", " componentCollectiveNoun:@"people" maximumWidth:[bounds CGRectValue].size.width inFont:font];
    }];
    
    RAC(self, participantsLabel.text) = participantStringSignal;
    RACSignal *isPrivate = RACObserve(self, viewModel.model.isPrivate);
    RAC(self, addParticipantsButton.hidden, @NO) = isPrivate;
    RAC(self, addParticipantsButtonWidthConstraint.constant, @(50)) = [isPrivate map:^id(id value) {
        return value && [value boolValue] ? @20 : @50;
    }];
    
    @weakify(self);
    self.addParticipantsButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *addButton) {
        @strongify(self);
        [self.viewModel showRecipientsPopoverInView:self fromButton:addButton];
        return [RACSignal empty];
    }];

    [super awakeFromNib];
}

@end
