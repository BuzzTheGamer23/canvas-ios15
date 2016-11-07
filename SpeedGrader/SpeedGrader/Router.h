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

@class CKCanvasAPI, CBIViewModel;

typedef UIViewController *(^RouteHandler)(NSDictionary *params, id sender);
typedef void(^DispatchHandler)(UIViewController *viewController);
typedef void(^FallbackHandler)(NSURL *url, UIViewController *sender);

@interface UIViewController (Routing)
- (void)applyRoutingParameters:(NSDictionary *)params;
@end

@interface Router : NSObject
@property CKCanvasAPI *canvasAPI;
@property (copy) FallbackHandler fallbackHandler;
+ (Router *)sharedRouter;

#pragma marks - Defining Routes
- (void)addRoute:(NSString *)route handler:(RouteHandler)handler;
- (void)addRoute:(NSString *)route forControllerClass:(Class)controllerClass;
- (void)addRoutesWithDictionary:(NSDictionary *)routes;

#pragma marks - Dispatching

/**
 @return the view controller that was routed to
 */
- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url;

@end
