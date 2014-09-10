//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 9/2/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDataSource.h"

@interface BLCLoginViewController ()<UIWebViewDelegate>

@property(nonatomic, weak) UIWebView *webView;
@property(nonatomic, strong) UIBarButtonItem *backButton;

@end

@implementation BLCLoginViewController

NSString *const BLCLoginViewControllerDidGetAccessTokenNotification =
    @"BLCLoginViewControllerDidGetAccessTokenNotification";

- (NSString *)redirectURI {
  return @"http://overlyhautz.com";
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)loadView {
  UIWebView *webView = [[UIWebView alloc] init];
  webView.delegate = self;

  self.webView = webView;
  self.view = webView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  NSString *urlString = [NSString
      stringWithFormat:@"https://instagram.com/oauth/authorize/"
                       @"?client_id=%@&redirect_uri=%@&response_type=token",
                       [BLCDataSource instagramClientID], [self redirectURI]];
  NSURL *url = [NSURL URLWithString:urlString];

  if (url) {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
  }

  self.title = NSLocalizedString(@"Login", @"Login");

  self.backButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(returnToLogin:)];
  [self.backButton setEnabled:NO];
  self.navigationItem.leftBarButtonItem = self.backButton;
}

- (void)updateButtonsAndTitle {
  NSString *webpageTitle =
      [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];

  if (webpageTitle) {
    self.title = webpageTitle;
  } else {
    self.title = self.webView.request.URL.absoluteString;
  }

  self.backButton.enabled = [self.webView canGoBack];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self updateButtonsAndTitle];
}

- (void)returnToLogin:(UIButton *)sender {
  [self.webView goBack];
}

- (void)dealloc {
  // Removing this line causes a weird flickering effect when you relaunch the
  // app after logging in, as the web view is briefly displayed, automatically
  // authenticates with cookies, returns the access token, and dismisses the
  // login view, sometimes in less than a second.
  [self clearInstagramCookies];

  // see
  // https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
  self.webView.delegate = nil;
}

/**
 Clears Instagram cookies. This prevents caching the credentials in the cookie
 jar.
 */
- (void)clearInstagramCookies {
  for (NSHTTPCookie *cookie in
       [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
    NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
    if (domainRange.location != NSNotFound) {
      [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
  }
}

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType {
  NSString *urlString = request.URL.absoluteString;
  if ([urlString hasPrefix:[self redirectURI]]) {
    // This contains our auth token
    NSRange rangeOfAccessTokenParameter =
        [urlString rangeOfString:@"access_token="];
    NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location +
                                      rangeOfAccessTokenParameter.length;
    NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification
                      object:accessToken];
    return NO;
  }

  return YES;
}

@end
