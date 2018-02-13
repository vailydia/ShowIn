//
//  SIMainView.h
//  ShowIN
//
//  Created by Weiling Xi on 12/26/17.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SIMainView : UIView

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITextView *navDetails;

@end
