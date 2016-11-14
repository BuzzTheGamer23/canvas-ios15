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
    
    

#import "CBILTIViewController.h"
#import "CBIExternalToolViewModel.h"
#import <CanvasKit1/CanvasKit1.h>


@implementation CBILTIViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, externalTool) = RACObserve(self, viewModel.model);
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat bottomInset = self.tabBarController.tabBar.bounds.size.height;
    self.toolbarBottomInsetConstraint.constant = -bottomInset;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}

@end
