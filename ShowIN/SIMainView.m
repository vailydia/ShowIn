//
//  SIMainView.m
//  ShowIN
//
//  Created by Weiling Xi on 12/26/17.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "SIMainView.h"

@interface SIMainView ()

@end

@implementation SIMainView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self _initMapViewWithFrame:CGRectMake( 0.0 , 0.0 , CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds) * 3 / 4)];
        [self _initSearchBar];
        [self _initDetailTextField];
        [self _initSubButtons];
    }
    return self;
}

#pragma mark - init subviews
- (void)_initMapViewWithFrame:(CGRect)frame {
    self.mapView = [[GMSMapView alloc] initWithFrame:frame];
    [self addSubview:self.mapView];
}

- (void)_initSearchBar {
    CGRect searchBarRect = CGRectMake( 5.0 , 22.0 , CGRectGetWidth(self.bounds) - 10.0, 40.0 );
    self.searchBar = [[UISearchBar alloc] initWithFrame:searchBarRect];
    self.searchBar.backgroundColor = UIColor.blueColor;
    self.searchBar.alpha = 0.6;
    [self addSubview:self.searchBar];
}

- (void)_initDetailTextField {
    CGRect detailsRect = CGRectMake(0.0 , CGRectGetHeight(self.bounds) * 3 / 4 , CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds) / 4);
    self.navDetails = [[UITextView alloc] init];
    self.navDetails.frame = detailsRect;
    
    self.navDetails.text = @"Positin: Haibor City";
    
    [self addSubview:self.navDetails];
}

- (void)_initSubButtons {
    self.navigationButton = [[UIButton alloc] init];
    self.navigationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.navigationButton.layer.cornerRadius = 10.0;
    [self.navigationButton setTitle:@"Navigation" forState:UIControlStateNormal];
    self.navigationButton.frame = CGRectMake( 250, 80, 100, 30 );
    self.navigationButton.backgroundColor = [UIColor colorWithRed:66/255 green:134/255 blue:244/255 alpha:0.8];
    [self.navigationButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    self.clearButton = [[UIButton alloc] init];
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.clearButton.layer.cornerRadius = 10.0;
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    self.clearButton.frame = CGRectMake( 250, 130, 100, 30 );
    self.clearButton.backgroundColor = [UIColor colorWithRed:66/255 green:134/255 blue:244/255 alpha:0.8];
    [self.clearButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [self addSubview:self.navigationButton];
    [self addSubview:self.clearButton];
}



@end
