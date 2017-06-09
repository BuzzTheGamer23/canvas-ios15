//
//  PSPDFSearchViewController.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"

#import "PSPDFAnnotation.h"
#import "PSPDFCache.h"
#import "PSPDFOverridable.h"
#import "PSPDFStyleable.h"
#import "PSPDFTextSearch.h"

@class PSPDFDocument, PSPDFViewController, PSPDFSearchResult, PSPDFSearchResultCell;

typedef NS_ENUM(NSInteger, PSPDFSearchStatus) {
    /// Search hasn't started yet.
    PSPDFSearchStatusIdle,
    /// Search operation is running.
    PSPDFSearchStatusActive,
    /// Search has been finished.
    PSPDFSearchStatusFinished,
    /// Search finished but there wasn't any content to search.
    PSPDFSearchStatusFinishedNoText,
    /// Search has been cancelled.
    PSPDFSearchStatusCancelled
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFSearchBarPinning) {
    /// Pin unless in a popover presentation.
    PSPDFSearchBarPinningAuto,
    /// Pin search bar to top.
    PSPDFSearchBarPinningTop,
    /// Embed the search bar inside the table view.
    PSPDFSearchBarPinningNone,
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, PSPDFSearchResultScope) {
    /// The search results shown with this scope are all from a given page range.
    PSPDFSearchResultScopePageRange,
    /// The search results shown with this scope are from the whole document.
    PSPDFSearchResultScopeDocument,
} PSPDF_ENUM_AVAILABLE;

@class PSPDFSearchViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol to integrate in a custom search result cell.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFSearchResultViewable<NSObject>

/**
 Configures the receiver to represent the passed in search result in the UI.

 @param searchResult The search result to represent by the receiver.
 */
- (void)configureWithSearchResult:(PSPDFSearchResult *)searchResult;

@end

/**
 Protocol to integrate in a custom header view that represents the scope of the
 current section.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFSearchScopeViewable<NSObject>

/**
 Configures the receiver to represent the passed in search scope.

 @param document The document that is being searched.
 @param scope The scope that is represented by this view.
 @param pageIndexRange The range of page indexes that will be represented by the scope.
 @param results The number of results inside scope.
 */
- (void)configureWithDocument:(PSPDFDocument *)document scope:(PSPDFSearchResultScope)scope pageIndexRange:(NSRange)pageIndexRange results:(NSUInteger)results;

@end

/**
 Protocol to integrate in a custom footer view that represents the current search
 status.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFSearchStatusViewable<NSObject>

/**
 Configures the receiver to represent the passed in search status in the UI.

 @param searchStatus The current status of the search.
 @param results The number of results found so far.
 @param pageIndex The page we are currently searching.
 @param pageCount The number of pages that will be searched.
 */
- (void)configureWithSearchStatus:(PSPDFSearchStatus)searchStatus results:(NSUInteger)results pageIndex:(NSUInteger)pageIndex pageCount:(NSUInteger)pageCount;

@end

/// Delegate for the search view controller.
/// @note This is a specialization of `PSPDFTextSearchDelegate`.
PSPDF_AVAILABLE_DECL @protocol PSPDFSearchViewControllerDelegate<PSPDFTextSearchDelegate, PSPDFOverridable>

@optional

/// Called when the user taps on a controller result cell.
- (void)searchViewController:(PSPDFSearchViewController *)searchController didTapSearchResult:(PSPDFSearchResult *)searchResult;

/// Will be called when the controller clears all search results.
- (void)searchViewControllerDidClearAllSearchResults:(PSPDFSearchViewController *)searchController;

/// Asks for the visible pages to optimize search ordering.
- (NSArray<NSNumber *> *)searchViewControllerGetVisiblePages:(PSPDFSearchViewController *)searchController;

/// Allows to narrow down the search range if a scope is set.
- (nullable NSIndexSet *)searchViewController:(PSPDFSearchViewController *)searchController searchRangeForScope:(NSString *)scope;

/// Requests the text search class. Creates a custom class if not implemented.
- (PSPDFTextSearch *)searchViewControllerTextSearchObject:(PSPDFSearchViewController *)searchController;

@end

/**
 The search view controller allows text and annotation searching within the current document.
 It uses `PSPDFTextView` under the hood and updates its delegate as results are loaded.

 Usually this is presented as a popover, but it also works modally.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchViewController : PSPDFBaseTableViewController<UISearchDisplayDelegate, UISearchBarDelegate, PSPDFTextSearchDelegate, PSPDFStyleable>

/**
 The class of the table view cell that is used to represent a search result.

 This method can be overridden to return a different class. The returned class has
 to be a subclass of `UITableViewCell` and needs to conform to `PSPDFSearchResultViewable`.

 In order to properly layout the table view, any instance of the returned class
 needs to be sizeable with auto layout.

 @note This method has to return a single class. Making the return value of this
       method dynamically return different classes in any way results in undefined
       behavior.

 @return A class object of the class that should be used to represent a single search
         result in the table view.
 */
+ (Class<PSPDFSearchResultViewable>)resultCellClass;

/**
 The class of the table view section header that is used to represent the scope
 of the current result section.

 The method can be overridden to return a different class. The returned class has
 to be a subclass of `UITableViewHeaderFooterView` and needs to conform to `PSPDFSearchScopeViewable`.

 A scope currently is only represented in the UI if the search view controller's
 `searchVisiblePagesFirst` returns `YES`.

 In order to properly layout the table view, any instance of the returned class
 needs to be sizeable with auto layout.

 @note This method has to return a single class. Making the return value of this
       method dynamically return different classes in any way results in undefined
       behavior.

 @return A class object of the class that should be used to represent the scope
         of the current section of results.
 */
+ (Class<PSPDFSearchScopeViewable>)scopeHeaderClass;

/**
 The class of the table view section footer that is used to represent the search
 status.

 The method can be overridden to return a different class. The returned class has
 to be a subclass of `UITableViewHeaderFooterView` and needs to conform to `PSPDFSearchStatusViewable`.

 A status currently is only represented in the UI if it is not idle (i.e. if the
 search has already been started).

 In order to properly layout the table view, any instance of the returned class
 needs to be sizeable with auto layout.

 @note This method has to return a single class. Making the return value of this
       method dynamically return different classes in any way results in undefined
       behavior.

 @return A class object of the class that should be used to represent the status
         of the current search in the table view.
 */
+ (Class<PSPDFSearchStatusViewable>)statusFooterClass;

/// Designated initializer.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// The current document.
@property (nonatomic, nullable) PSPDFDocument *document;

/// The search view controller delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFSearchViewControllerDelegate> delegate;

/// Current searchText. If set before showing the controller, keyboard will not be added.
@property (nonatomic, copy, nullable) NSString *searchText;

/// Different behavior depending on size classes.
@property (nonatomic) BOOL showsCancelButton;

/// Search bar for controller.
/// @warning You can change attributes (e.g. `barStyle`) but don't change the searchBar delegate.
@property (nonatomic, readonly) UISearchBar *searchBar;

/// Current search status. KVO observable.
@property (nonatomic, readonly) PSPDFSearchStatus searchStatus;

/// Clears highlights when controller disappears. Defaults to NO.
@property (nonatomic) BOOL clearHighlightsWhenClosed;

/// Defaults to 600. A too high number will be slow.
@property (nonatomic) NSUInteger maximumNumberOfSearchResultsDisplayed;

/// Set to enable searching on the visible pages, then all. Defaults to NO.
/// If not set, the natural page order is searched.
@property (nonatomic) BOOL searchVisiblePagesFirst;

/// Number of lines to show preview text. Defaults to 2.
@property (nonatomic) NSUInteger numberOfPreviewTextLines;

/// Searches the outline for the most matching entry, displays e.g. "Section 100, Page 2" instead of just "Page 2".
/// Defaults to YES.
@property (nonatomic) BOOL useOutlineForPageNames;

/// The last search result is restored in `viewWillAppear:` if the document UID matches the last used one.
/// This search result is only persisted in memory. Defaults to YES.
/// @note Needs to be set before the view controller is presented to have an effect.
@property (nonatomic) BOOL restoreLastSearchResult;

/// Will include annotations that have a matching type into the search results. (contents will be searched).
/// Defaults to PSPDFAnnotationTypeAll&~PSPDFAnnotationTypeLink.
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic) PSPDFAnnotationType searchableAnnotationTypes;

/// Determines the searchbar positioning. Defaults to PSPDFSearchBarPinningAuto.
@property (nonatomic) PSPDFSearchBarPinning searchBarPinning;

/// Internally used `PSPDFTextSearch` object.
/// (is a copy of the PSPDFTextSearch class in document)
@property (nonatomic, readonly, nullable) PSPDFTextSearch *textSearch;

/// Call to force a search restart. Useful if the underlying content has changed.
- (void)restartSearch;

@end

@interface PSPDFSearchViewController (SubclassingHooks)

/// Called every time the text in the search bar changes.
- (void)filterContentForSearchText:(NSString *)searchText scope:(nullable NSString *)scope;

/// Will update the status and insert/reload/remove search rows
- (void)setSearchStatus:(PSPDFSearchStatus)searchStatus updateTable:(BOOL)updateTable;

/// Returns the searchResult for a cell.
- (PSPDFSearchResult *)searchResultForIndexPath:(NSIndexPath *)indexPath;

/// Will return a searchbar. Called during `viewDidLoad`. Use to customize the toolbar.
/// This method does basic properties like `tintColor`, `showsCancelButton` and `placeholder`.
/// After calling this, the delegate will be set to this class.
@property (nonatomic, readonly) UISearchBar *createSearchBar;

/// Currently loaded search results.
@property (nonatomic, readonly) NSArray<PSPDFSearchResult *> *searchResults;

@end

NS_ASSUME_NONNULL_END
