#import "SafariViewController.h"

@implementation SafariViewController
{
  SFSafariViewController *vc;
}

- (void) isAvailable:(CDVInvokedUrlCommand*)command {
  bool avail = NSClassFromString(@"SFSafariViewController") != nil;
  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:avail];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) show:(CDVInvokedUrlCommand*)command {
  NSDictionary* options = [command.arguments objectAtIndex:0];
  NSString* urlString = options[@"url"];
  if (urlString == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"url can't be empty"] callbackId:command.callbackId];
    return;
  }
  if (![[urlString lowercaseString] hasPrefix:@"http"]) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"url must start with http or https"] callbackId:command.callbackId];
    return;
  }
  NSURL *url = [NSURL URLWithString:urlString];
  if (url == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"bad url"] callbackId:command.callbackId];
    return;
  }

  self.animated = [options[@"animated"] isEqual:[NSNumber numberWithBool:YES]];
  self.disableSharing = [options[@"disableSharing"] isEqual:[NSNumber numberWithBool:YES]];
  self.callbackId = command.callbackId;

  SFSafariViewControllerConfiguration *config = [[SFSafariViewControllerConfiguration alloc] init];
  config.barCollapsingEnabled = [options[@"barCollapsingEnabled"] isEqual:[NSNumber numberWithBool:YES]];;
  config.entersReaderIfAvailable = [options[@"enterReaderModeIfAvailable"] isEqual:[NSNumber numberWithBool:YES]];
  
  vc = [[SFSafariViewController alloc] initWithURL:url configuration:config];
  vc.delegate = self;

  bool hidden = [options[@"hidden"] isEqualToNumber:[NSNumber numberWithBool:YES]];
  if (hidden) {
    vc.view.userInteractionEnabled = NO;
    vc.view.alpha = 0.05;
    [self.viewController addChildViewController:vc];
    [self.viewController.view addSubview:vc.view];
    [vc didMoveToParentViewController:self.viewController];
    vc.view.frame = CGRectMake(0.0, 0.0, 0.5, 0.5);
  } else {
    [self.viewController presentViewController:vc animated:self.animated completion:nil];
  }

  int dismissButtonStyle = (int)[(NSNumber *)options[@"dismissButtonStyle"] integerValue];
  vc.dismissButtonStyle = dismissButtonStyle * (dismissButtonStyle < 3);

  NSString *controlTintColor = options[@"controlTintColor"];
  if (controlTintColor != nil) {
      vc.preferredControlTintColor = [self colorFromHexString:controlTintColor];
  }

  NSString *barColor = options[@"toolbarColor"];
  if (barColor != nil) {
    vc.preferredBarTintColor = [self colorFromHexString:barColor];
  }

  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"opened"}];
  [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) hide:(CDVInvokedUrlCommand*)command {
  SFSafariViewController *childVc = [self.viewController.childViewControllers lastObject];
  if (childVc != nil) {
    [childVc willMoveToParentViewController:nil];
    [childVc.view removeFromSuperview];
    [childVc removeFromParentViewController];
    childVc = nil;
  }
  
  if (vc != nil) {
    [vc dismissViewControllerAnimated:self.animated completion:nil];
    vc = nil;
  }
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

# pragma mark - SFSafariViewControllerDelegate

/*! @abstract Delegate callback called when the user taps the Done button.
    Upon this call, the view controller is dismissed modally.
 */
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  if (self.callbackId != nil) {
    NSString * cbid = [self.callbackId copy];
    self.callbackId = nil;
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"closed"}];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:cbid];
  }
}

/*! @abstract Invoked when the initial URL load is complete.
    @param success YES if loading completed successfully, NO if loading failed.
    @discussion This method is invoked when SFSafariViewController completes the loading of the URL that you pass
    to its initializer. It is not invoked for any subsequent page loads in the same SFSafariViewController instance.
 */
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  if (self.callbackId != nil) {
    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"loaded"}];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
  }
}


- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)
              controller activityItemsForURL:(NSURL *)URL
              title:(nullable NSString *)title {

    if (self.activityItemProvider)
        return [self.activityItemProvider safariViewController:controller activityItemsForURL:URL title:title];
    else
        return nil;
        
}

- (NSArray<UIActivityType> *)safariViewController:(SFSafariViewController *)controller
									excludedActivityTypesForURL:(NSURL *)URL
                                    title:(nullable NSString *)title {
	if (self.disableSharing)
	return @[
		UIActivityTypeAddToReadingList,
		UIActivityTypeAirDrop,
		UIActivityTypeAssignToContact,
		UIActivityTypeCopyToPasteboard,
		UIActivityTypeMail,
		UIActivityTypeMarkupAsPDF,
		UIActivityTypeMessage,
		UIActivityTypeOpenInIBooks,
		UIActivityTypePostToFacebook,
		UIActivityTypePostToFlickr,
		UIActivityTypePostToTencentWeibo,
		UIActivityTypePostToTwitter,
		UIActivityTypePostToVimeo,
		UIActivityTypePostToWeibo,
		UIActivityTypePrint,
		UIActivityTypeSaveToCameraRoll,
		

		/* does not work
		@"com.apple.mobilenotes.SharingExtension",
		@"com.apple.reminders.RemindersEditorExtension",
		@"com.apple.CloudDocsUI.AddToiCloudDrive",
		@"com.amazon.Lassen.SendToKindleExtension",
		@"com.google.chrome.ios.ShareExtension",
		@"com.google.Drive.ShareExtension",
		@"com.google.Gmail.ShareExtension",
		@"com.google.inbox.ShareExtension",
		@"com.google.hangouts.ShareExtension",
		@"com.iwilab.KakaoTalk.Share",
		@"com.facebook.Messenger.ShareExtension",
		@"com.nhncorp.NaverSearch.ShareExtension",
		@"com.linkedin.LinkedIn.ShareExtension",
		@"net.whatsapp.WhatsApp.ShareExtension",
		@"com.tinyspeck.chatlyio.share", // Slack!
		@"ph.telegra.Telegraph.Share",
		@"com.toyopagroup.picaboo.share", // Snapchat!
		@"com.fogcreek.trello.trelloshare",
		@"com.hammerandchisel.discord.Share",
		@"com.riffsy.RiffsyKeyboard.RiffsyShareExtension", //GIF Keyboard by Tenor
		@"com.ifttt.ifttt.share",
		@"com.getdropbox.Dropbox.ActionExtension",
		@"wefwef.YammerShare",
		@"pinterest.ShareExtension",
		@"pinterest.ActionExtension",
		@"us.zoom.videomeetings.Extension",
		*/

	];
	else return nil;
}

@end
