//
//  TSQueryTableViewController.h
//  Temi Svolti
//
//  Created by Eugenio Baglieri on 17/03/15.
//  Copyright (c) 2015 Eugenio Baglieri. All rights reserved.
//

//  This is the super class of all app's TableViewControllers

#import <ParseUI/ParseUI.h>

@interface TSQueryTableViewController : PFQueryTableViewController

@property (strong, nonatomic) UIView *footerLoadingView;
@property (nonatomic, assign) BOOL automaticallyLoadsNextPage;

@end
