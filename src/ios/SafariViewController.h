#import <Cordova/CDVPlugin.h>
#import <SafariServices/SafariServices.h>

@protocol ActivityItemProvider

- (NSArray<UIActivity *> *_Nullable)	safariViewController:(SFSafariViewController *_Nullable)controller
										activityItemsForURL:(NSURL *_Nonnull)URL
										title:(nullable NSString *)title;

- (NSArray<UIActivityType> *_Nullable)	safariViewController:(SFSafariViewController *_Nullable)controller 
										excludedActivityTypesForURL:(NSURL *_Nonnull)URL 
										title:(NSString *_Nullable)title;
@end

@interface SafariViewController : CDVPlugin <SFSafariViewControllerDelegate>

@property (nonatomic, copy) NSString* _Nullable callbackId;
@property (nonatomic) bool animated;
@property (nonatomic) bool disableSharing;
@property (nonatomic) id<ActivityItemProvider> _Nullable activityItemProvider;

- (void) isAvailable:(CDVInvokedUrlCommand*_Nonnull)command;
- (void) show:(CDVInvokedUrlCommand*_Nonnull)command;
- (void) hide:(CDVInvokedUrlCommand*_Nonnull)command;

@end
