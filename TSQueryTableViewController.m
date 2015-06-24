//
//  TSQueryTableViewController.m
//  Temi Svolti
//
//  Created by Eugenio Baglieri on 17/03/15.
//  Copyright (c) 2015 Eugenio Baglieri. All rights reserved.
//

#import "TSQueryTableViewController.h"
#import <objc/runtime.h>

@interface TSQueryTableViewController ()

@end

@implementation TSQueryTableViewController

#warning This is an hack to support infinite scrolling, caution on Parse Framework updates
#pragma mark - Method Swizzling

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(_shouldShowPaginationCell);
        SEL swizzledSelector = @selector(new_shouldShowPaginationCell);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (BOOL)new_shouldShowPaginationCell
{
    if (self.automaticallyLoadsNextPage) {
        return NO;
    }
    return [self _shouldLoadNextPage];
}

- (BOOL)_shouldLoadNextPage
{
    return [self new_shouldShowPaginationCell];
}

#pragma mark Superclass Methods overriding

// Override loadNextPage and objectsDidLoad to show a loading view in tableView's footer, when infinite scrolling is active

- (void)loadNextPage
{
    if (self.automaticallyLoadsNextPage) {
         self.tableView.tableFooterView = self.footerLoadingView;
    }
    [super loadNextPage];
}

- (void)objectsDidLoad:(NSError *)error
{
    
    if ([self.footerLoadingView superview] != nil) {
        self.tableView.tableFooterView = nil;
    }
    [super objectsDidLoad:error];
}

#pragma mark - UIScrollviewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.automaticallyLoadsNextPage) {
        CGFloat actualPosition = scrollView.contentOffset.y;
        CGFloat viewHeight = scrollView.bounds.size.height;
        CGFloat contentHeight = scrollView.contentSize.height;
        if (contentHeight > viewHeight &&
            //is 1.2 a good value? it seems yes
            actualPosition +  ( 1.0 * viewHeight) > contentHeight ) {
            if (![self isLoading] && [self _shouldLoadNextPage]) {
                [self loadNextPage];
            }
        }
    }
}

#pragma mark - ()

- (UIView *)footerLoadingView
{
    if (_footerLoadingView == nil) {
        CGRect footerViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 50.0);
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect activityIndicatorFrame = activityIndicator.frame;
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        activityIndicator.frame = CGRectMake((CGRectGetWidth(footerViewFrame) - CGRectGetWidth(activityIndicatorFrame)) / 2 ,
                                             (CGRectGetHeight(footerViewFrame) - CGRectGetHeight(activityIndicatorFrame)) / 2,
                                             CGRectGetWidth(activityIndicatorFrame),
                                             CGRectGetHeight(activityIndicatorFrame));
        activityIndicator.color = [UIColor darkGrayColor];
        [activityIndicator startAnimating];
        
        _footerLoadingView  = [[UIView alloc] initWithFrame:footerViewFrame];
        _footerLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_footerLoadingView addSubview:activityIndicator];
        
    }
    return _footerLoadingView;
}

@end
