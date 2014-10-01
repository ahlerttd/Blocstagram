//
//  BLCPostToInstagramCollectionViewCell.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 9/30/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCPostToInstagramCollectionViewCell.h"

@implementation BLCPostToInstagramCollectionViewCell


- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailSize, self.thumbnailSize)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    [self.contentView addSubview:self.imageView];


    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailSize, self.thumbnailSize, 20)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    [self.contentView addSubview:self.label];


    return self;
    
}

- (void) setThumbnailSize:(CGFloat)thumbnailSize {
    
    self.imageView.frame = CGRectMake(0, 0, thumbnailSize, thumbnailSize);
    self.label.frame = CGRectMake(0, thumbnailSize, thumbnailSize, 20);
    
}

@end
