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

@interface BLCImagesTableViewController () <BLCMediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;

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
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[BLCDataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
}

- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[BLCDataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void) refreshTable {
    [BLCDataSource sharedInstance];
    
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
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

@end
