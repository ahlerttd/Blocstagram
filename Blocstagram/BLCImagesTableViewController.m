//
//  BLCImagesTableViewController.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/22/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCImagesTableViewController.h"
#import "BLCDataSource.h"
#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCComment.h"
#import "BLCMediaTableViewCell.h"
#import "BLCMediaFullScreenViewController.h"
#import "BLCMediaFullScreenAnimator.h"
#import "BLCCameraViewController.h"

 @interface BLCImagesTableViewController () <BLCMediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, BLCCameraViewControllerDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;

@end

@implementation BLCImagesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)loadView {
  [super loadView];
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [[BLCDataSource sharedInstance] addObserver:self
                                   forKeyPath:@"mediaItems"
                                      options:0
                                      context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];

    

    
  [self.tableView registerClass:[BLCMediaTableViewCell class]
         forCellReuseIdentifier:@"mediaCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];



}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[BLCDataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[BLCDataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void) refreshTable {
    [BLCDataSource sharedInstance];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == [BLCDataSource sharedInstance] &&
      [keyPath isEqualToString:@"mediaItems"]) {
    // We know mediaItems changed.  Let's see what kind of change it is.
    int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];

    if (kindOfChange == NSKeyValueChangeSetting) {
      // Someone set a brand new images array
      [self.tableView reloadData];
    } else if (kindOfChange == NSKeyValueChangeInsertion ||
               kindOfChange == NSKeyValueChangeRemoval ||
               kindOfChange == NSKeyValueChangeReplacement) {
      // We have an incremental change: inserted, deleted, or replaced images

      // Get a list of the index (or indices) that changed
      NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];

      // Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what
      // the table view animation methods require)
      NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
      [indexSetOfChanges
          enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
              NSIndexPath *newIndexPath =
                  [NSIndexPath indexPathForRow:idx inSection:0];
              [indexPathsThatChanged addObject:newIndexPath];
          }];

      // Call `beginUpdates` to tell the table view we're about to make changes
      [self.tableView beginUpdates];

      // Tell the table view what the changes are
      if (kindOfChange == NSKeyValueChangeInsertion) {
        [self.tableView
            insertRowsAtIndexPaths:indexPathsThatChanged
                  withRowAnimation:UITableViewRowAnimationAutomatic];
      } else if (kindOfChange == NSKeyValueChangeRemoval) {
        [self.tableView
            deleteRowsAtIndexPaths:indexPathsThatChanged
                  withRowAnimation:UITableViewRowAnimationAutomatic];
      } else if (kindOfChange == NSKeyValueChangeReplacement) {
        [self.tableView
            reloadRowsAtIndexPaths:indexPathsThatChanged
                  withRowAnimation:UITableViewRowAnimationAutomatic];
      }

      // Tell the table view that we're done telling it about changes, and to
      // complete the animation
      [self.tableView endUpdates];
    }
  }
}

- (NSMutableArray *)items {
  return [BLCDataSource sharedInstance].mediaItems;
  ;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        
        return 450;
    } else {
        
        return 250;
    }
}

#pragma mark - Camera and BLCCameraViewControllerDelegate

- (void) cameraPressed:(UIBarButtonItem *) sender {
    BLCCameraViewController *cameraVC = [[BLCCameraViewController alloc] init];
    cameraVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraVC];
    [self presentViewController:nav animated:YES completion:nil];
    return;
}

- (void) cameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
    [cameraViewController dismissViewControllerAnimated:YES completion:^{
        if (image) {
            NSLog(@"Got an image!");
        } else {
            NSLog(@"Closed without an image.");
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BLCMediaTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"mediaCell"
                                      forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];

  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCMediaTableViewCell *cell = (BLCMediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.dragging) {
        BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
        if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
            [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  BLCMedia *item = [self items][indexPath.row];
  return [BLCMediaTableViewCell
      heightForMediaItem:item
                   width:CGRectGetWidth(self.view.frame)];
}



- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  // If row is deleted, remove it from the list.
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    BLCMedia *item = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
    [[BLCDataSource sharedInstance] deleteMediaItem:item];
  }
}

- (void) infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [BLCDataSource sharedInstance].mediaItems.count - 1) {
        // The very last cell is on screen
        [[BLCDataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}


- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell {
    [[BLCDataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.dragging){
        NSArray *index = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in index) {
            BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
            if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
                [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
            }
        }
    }
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    NSArray *index = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in index) {
        BLCMedia *mediaItem = [BLCDataSource sharedInstance].mediaItems[indexPath.row];
        if (mediaItem.downloadState == BLCMediaDownloadStateNeedsImage) {
            [[BLCDataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        }
    }
}


#pragma mark - BLCMediaTableViewCellDelegate

- (void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    
    BLCMediaFullScreenViewController *fullScreenVC = [[BLCMediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    fullScreenVC.transitioningDelegate = self;
    fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}


- (void) cell:(BLCMediaTableViewCell *)cell didTwoTapImageView:(UIImageView *)imageView {
   
    [[BLCDataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}

- (void) cellWillStartComposingComment:(BLCMediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void) cell:(BLCMediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[BLCDataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    BLCMediaFullScreenAnimator *animator = [BLCMediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    NSLog(@"Difference %2F", difference);
    
    if (difference > 0) {
        heightToScroll += difference;
        
    }
    

    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
        ///CGFloat commentViewHeight = CGRectGetHeight(commentViewFrameInViewCoordinates);
        ///NSLog(@"CommentViewHeight: %2F", commentViewHeight);
        NSLog(@"HeightToScroll %2F", heightToScroll);
    }
    
    if (heightToScroll > 0) {
        NSLog(@"Show Keyboard ContentInsets.bottom %2F", contentInsets.bottom);
       
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSLog(@"Show Keyboard Add HeightToScroll ContentInsets.bottom %2F", contentInsets.bottom);
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustment = heightToScroll;
    NSLog(@"Last Keyboard Adjust %2F", self.lastKeyboardAdjustment);
}



- (void)keyboardWillHide:(NSNotification *)notification
{
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    NSLog(@"Hide Keyboard Content Inset Bottom %2F", contentInsets.bottom);
    contentInsets.bottom -= self.lastKeyboardAdjustment;
    NSLog(@"Hide Keyboard contentInsetBottom After lastKeyboardAdjustment %2F", contentInsets.bottom);
    ///NSLog(@"Last Keyboard Adjustment: %2F", self.lastKeyboardAdjustment);
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    
    
}

@end
