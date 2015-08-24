#import "RANCViewController.h"
#import "RAHostedAppView.h"
#import "RASettings.h"
#import "headers.h"

@interface SBNotificationCenterViewController <UITextFieldDelegate>
-(id)_newBulletinObserverViewControllerOfClass:(Class)aClass;
-(void) _addBulletinObserverViewController:(id)arg1;
@end

NSString *getAppName()
{
	NSString *ident = [RASettings.sharedInstance NCApp] ?: @"com.apple.Preferences";
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:ident];
	return app ? app.displayName : nil;
}

RANCViewController *ncAppViewController;

%hook SBNotificationCenterViewController
- (void)viewWillAppear:(BOOL)animated 
{
   	%orig;

   	if ([RASettings.sharedInstance NCAppEnabled])
   	{
		SBNotificationCenterViewController* modeVC = MSHookIvar<id>(self, "_modeController");
		if (ncAppViewController == nil) 
			ncAppViewController = [self _newBulletinObserverViewControllerOfClass:[RANCViewController class]];
		[modeVC _addBulletinObserverViewController:ncAppViewController];
	}
}

+ (NSString *)_localizableTitleForBulletinViewControllerOfClass:(__unsafe_unretained Class)aClass
{
	if (aClass == [RANCViewController class]) 
	{
		BOOL useGenericLabel = THEMED(quickAccessUseGenericTabLabel);
		if (useGenericLabel)
			return LOCALIZE(@"APP");
		return ncAppViewController.hostedApp.displayName ?: getAppName() ?: LOCALIZE(@"APP");
	}
	else 
		return %orig;
}
%end