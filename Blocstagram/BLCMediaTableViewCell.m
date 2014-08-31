//
//  BLCMediaTableViewCell.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/27/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCMediaTableViewCell.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCUser.h"

@interface BLCMediaTableViewCell ()
@property(nonatomic, strong) UIImageView *mediaImageView;
@property(nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property(nonatomic, strong) UILabel *commentLabel;

@property(nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *imageWidthConstraint;
@property(nonatomic, strong)
    NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;


#define LAYOUT_NORMAL 0
#define LAYOUT_HORIZONTAL 1

#define LAYOUT_OPTION LAYOUT_HORIZONTAL

@implementation BLCMediaTableViewCell

+ (void)load {
  lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
  boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
  usernameLabelGray =
      [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeee**/
  commentLabelGray =
      [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
  linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];

  NSMutableParagraphStyle *mutableParagraphStyle =
      [[NSMutableParagraphStyle alloc] init];
  mutableParagraphStyle.headIndent = 20.0;
  mutableParagraphStyle.firstLineHeadIndent = 20.0;
  mutableParagraphStyle.tailIndent = -20.0;
  mutableParagraphStyle.paragraphSpacingBefore = 5;

  paragraphStyle = mutableParagraphStyle;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.mediaImageView = [[UIImageView alloc] init];
    self.usernameAndCaptionLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.adjustsFontSizeToFitWidth = YES;
    [self.commentLabel
        setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                        forAxis:UILayoutConstraintAxisHorizontal];

    for (UIView *view in @[
           self.mediaImageView,
           self.usernameAndCaptionLabel,
           self.commentLabel
         ]) {
      [self.contentView addSubview:view];
      view.translatesAutoresizingMaskIntoConstraints = NO;
    }

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(
        _mediaImageView, _usernameAndCaptionLabel, _commentLabel);

    ///[self.contentView addConstraints:[NSLayoutConstraint
    /// constraintsWithVisualFormat:@"H:|[_mediaImageView](10)|"
    /// options:kNilOptions metrics:nil views:viewDictionary]];/
    ///[self.contentView addConstraints:[NSLayoutConstraint
    /// constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel]|"
    /// options:kNilOptions metrics:nil views:viewDictionary]];
    /// [self.contentView addConstraints:[NSLayoutConstraint
    /// constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions
    /// metrics:nil views:viewDictionary]];

    [self.contentView
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|[_mediaImageView]-[_usernameAndCaptionLabel(10)]-[_commentLabel]|"
                                               options:kNilOptions
                                               metrics:nil
                                                 views:viewDictionary]];
      
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
      
      
      

    [self.contentView addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.mediaImageView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:self.contentView
                                                 attribute:NSLayoutAttributeTop
                                                multiplier:1.0
                                                  constant:0]];

    [self.contentView
        addConstraint:[NSLayoutConstraint
                          constraintWithItem:_usernameAndCaptionLabel
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:_mediaImageView
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:0]];

    [self.contentView
        addConstraint:[NSLayoutConstraint
                          constraintWithItem:_commentLabel
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:_usernameAndCaptionLabel
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:0]];
      
      [self.contentView
       addConstraint:[NSLayoutConstraint
                      constraintWithItem:_commentLabel
                      attribute:NSLayoutAttributeBottom
                      relatedBy:NSLayoutRelationEqual
                      toItem:self.mediaImageView
                      attribute:NSLayoutAttributeBottom
                      multiplier:1.0
                      constant:0]];

    self.imageHeightConstraint =
        [NSLayoutConstraint constraintWithItem:_mediaImageView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:100];


    self.usernameAndCaptionLabelHeightConstraint =
        [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:100];

    self.commentLabelHeightConstraint =
        [NSLayoutConstraint constraintWithItem:_commentLabel
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:100];

    [self.contentView
        addConstraints:@[
                         self.imageHeightConstraint,
                         self.usernameAndCaptionLabelHeightConstraint,
                         self.commentLabelHeightConstraint
                       ]];
  }
  return self;
}

- (NSAttributedString *)usernameAndCaptionString {
  CGFloat usernameFontSize = 8;

  // Make a string that says "username caption text"
  NSString *baseString =
      [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName,
                                 self.mediaItem.caption];

  // Make an attributed string, with the "username" bold
  NSMutableAttributedString *mutableUsernameAndCaptionString =
      [[NSMutableAttributedString alloc]
          initWithString:baseString
              attributes:@{
                           NSFontAttributeName :
                               [lightFont fontWithSize:usernameFontSize],
                           NSParagraphStyleAttributeName : paragraphStyle
                         }];

  NSRange usernameRange =
      [baseString rangeOfString:self.mediaItem.user.userName];
  [mutableUsernameAndCaptionString
      addAttribute:NSFontAttributeName
             value:[boldFont fontWithSize:usernameFontSize]
             range:usernameRange];
  [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName
                                          value:linkColor
                                          range:usernameRange];

  return mutableUsernameAndCaptionString;
}

- (NSAttributedString *)commentString {
  NSMutableAttributedString *commentString =
      [[NSMutableAttributedString alloc] init];
  CGFloat commentFontSize = 6;

  for (BLCComment *comment in self.mediaItem.comments) {
    // Make a string that says "username comment text" followed by a line break
    NSString *baseString = [NSString
        stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];

    // Make an attributed string, with the "username" bold

    NSMutableAttributedString *oneCommentString =
        [[NSMutableAttributedString alloc]
            initWithString:baseString
                attributes:@{
                             NSFontAttributeName : lightFont,
                             NSParagraphStyleAttributeName : paragraphStyle
                           }];

    NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
    [oneCommentString addAttribute:NSFontAttributeName
                             value:[boldFont fontWithSize:commentFontSize]
                             range:usernameRange];
    [oneCommentString addAttribute:NSForegroundColorAttributeName
                             value:linkColor
                             range:usernameRange];

    [commentString appendAttributedString:oneCommentString];
  }

  return commentString;
}

- (void)layoutSubviews {
  [super layoutSubviews];

#if (LAYOUT_OPTION == LAYOUT_NORMAL)
  CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
  CGSize usernameLabelSize =
      [self.usernameAndCaptionLabel sizeThatFits:maxSize];
  CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];

  self.usernameAndCaptionLabelHeightConstraint.constant =
      usernameLabelSize.height + 20;
  self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;

#elif(LAYOUT_OPTION == LAYOUT_HORIZONTAL)
  self.usernameAndCaptionLabelHeightConstraint.constant =
      self.mediaImageView.bounds.size.height;
  self.commentLabelHeightConstraint.constant =
      self.mediaImageView.bounds.size.height;
#endif

  // Hide the line between cells
  self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

- (void)setMediaItem:(BLCMedia *)mediaItem {
  _mediaItem = mediaItem;
  self.mediaImageView.image = _mediaItem.image;
  self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
  self.commentLabel.attributedText = [self commentString];

  self.imageHeightConstraint.constant =
      self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);

  [self setNeedsLayout];
  [self layoutIfNeeded];
}

+ (CGFloat)heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width {
  BLCMediaTableViewCell *layoutCell =
      [[BLCMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:@"layoutCell"];

  layoutCell.mediaItem = mediaItem;
  layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));

  [layoutCell setNeedsLayout];
  [layoutCell layoutIfNeeded];

#if (LAYOUT_OPTION == LAYOUT_NORMAL)
  // Make a cell
  return CGRectGetMaxY(layoutCell.commentLabel.frame);
#elif(LAYOUT_OPTION == LAYOUT_HORIZONTAL)
  return CGRectGetMaxY(layoutCell.mediaImageView.frame);
#endif
}

@end
