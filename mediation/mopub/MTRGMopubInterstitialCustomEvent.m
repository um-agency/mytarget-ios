//
//  MTRGMopubInterstitialCustomEvent.m
//  myTargetSDKMopubMediation
//
//  Created by Anton Bulankin on 16.02.15.
//  Copyright (c) 2015 Mail.ru Group. All rights reserved.
//

#import "MTRGMopubInterstitialCustomEvent.h"
#import "MTRGInterstitialAd.h"
#import "MTRGError.h"

@interface MTRGMopubInterstitialCustomEvent () <MTRGInterstitialAdDelegate>

@end

@implementation MTRGMopubInterstitialCustomEvent
{
	MTRGInterstitialAd *_interstitialAd;
	BOOL _alreadyDisappear;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
	_alreadyDisappear = NO;
	NSUInteger slotId;

	if (info)
	{
		id slotIdValue = [info valueForKey:@"slotId"];
        slotId = [self parseSlotId:slotIdValue];        
	}

	if (slotId)
	{
		_interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
		_interstitialAd.delegate = self;
		[_interstitialAd load];
	}
	else
	{
		MTRGError *mtrgError = [MTRGError errorWithTitle:@"Options is not correct. slotId not found"];
		[self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[mtrgError asError]];

	}
}

-(NSUInteger) parseSlotId:(id)slotIdValue{
    if ([slotIdValue isKindOfClass:[NSString class]])
    {
        NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
        NSNumber * slotIdNum = [formatString numberFromString:slotIdValue];
        return slotIdNum ? [slotIdNum unsignedIntegerValue] : 0;
    }
    else if ([slotIdValue isKindOfClass:[NSNumber class]])
        return[((NSNumber*)slotIdValue) unsignedIntegerValue];
    return 0;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
	[_interstitialAd showWithController:rootViewController];
	[self.delegate trackImpression];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
	return NO;
}

- (void)onLoadWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)onNoAdWithReason:(NSString *)reason interstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	NSError *error = nil;
	if (reason)
	{
		MTRGError *mtrgError = [MTRGError errorWithTitle:@"No ad" desc:reason];
		error = [mtrgError asError];
	}
	[self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	[self.delegate trackClick];
	[self disappear];
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd
{
	//empty
	[self disappear];
}

- (void)disappear
{
	if (!_alreadyDisappear)
	{
		[self.delegate interstitialCustomEventDidDisappear:self];
		_alreadyDisappear = YES;
	}
}

@end