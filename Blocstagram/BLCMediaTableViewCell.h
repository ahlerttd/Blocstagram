//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/27/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia, BLCMediaTableViewCell;

@protocol BLCMediaTableViewCellDelegate <NSObject>

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didTwoTapImageView:(UIImageView *)imageView;
- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell;

@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
@property (nonatomic, weak) id <BLCMediaTableViewCellDelegate> delegate;

 + (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;

@end
