#import "RNAppTour.h"
#import <React/RCTEventDispatcher.h>
#import "ViewPartition.h"

NSString *const onStartShowStepEvent = @"onStartShowCaseEvent";
NSString *const onShowSequenceStepEvent = @"onShowSequenceStepEvent";
NSString *const onFinishShowStepEvent = @"onFinishSequenceEvent";

@implementation MutableOrderedDictionary {
@protected
    NSMutableArray *_values;
    NSMutableOrderedSet *_keys;
}

- (instancetype)init {
    if ((self = [super init])) {
        _values = NSMutableArray.new;
        _keys = NSMutableOrderedSet.new;
    }
    return self;
}

- (NSUInteger)count {
    return _keys.count;
}

- (NSEnumerator *)keyEnumerator {
    return _keys.objectEnumerator;
}

- (void)removeObjectForKey:(id)key {
    [_values removeObjectAtIndex:[_keys indexOfObject: key]];
    [_keys removeObject:key];
}

- (id)objectForKey:(id)key {
    NSUInteger index = [_keys indexOfObject:key];
    if (index != NSNotFound){
        return _values[index];
    }
    return nil;
}


- (void)setObject:(id)object forKey:(id)key {
    NSUInteger index = [_keys indexOfObject:key];
    if (index != NSNotFound) {
        _values[index] = object;
    } else {
        [_keys addObject:key];
        [_values addObject:object];
    }
}

@end

@implementation RNAppTour

@synthesize delegate;

@synthesize bridge = _bridge;

- (id)init {
    self = [super init];
    if (self) {
        targets = [[MutableOrderedDictionary alloc] init];
    }
    
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


- (NSTextAlignment*) getTextAlignmentByString: (NSString*) strAlignment {
    if (strAlignment == nil) {
        return NSTextAlignmentLeft; // default is left
    }
    
    NSString *lowCaseString = [strAlignment lowercaseString];
    if ([lowCaseString isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    } if ([lowCaseString isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    } if ([lowCaseString isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    } if ([lowCaseString isEqualToString:@"justify"]) {
        return NSTextAlignmentJustified;
    }
    
    return NSTextAlignmentLeft;
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
            case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
            case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
            case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
            case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            return nil;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(ShowSequence:(NSArray *)views props:(NSDictionary *)props)
{
    targets = [[MutableOrderedDictionary alloc] init];
    for (NSNumber *view in views) {
        [targets setObject:[props objectForKey: [view stringValue]] forKey: [view stringValue]];
    }
    
    NSString *showTargetKey = [ [targets allKeys] objectAtIndex: 0];
    [self ShowFor:[NSNumber numberWithLongLong:[showTargetKey longLongValue]] props:[targets objectForKey:showTargetKey] ];
}

- (void)showCaseWillDismissWithShowcase:(MaterialShowcase *)materialShowcase {
    NSLog(@"");
}
- (void)showCaseDidDismissWithShowcase:(MaterialShowcase *)materialShowcase {
    NSLog(@"");
    
    NSArray *targetKeys = [targets allKeys];
    if (targetKeys.count <= 0) {
        return;
    }
    
    NSString *removeTargetKey = [targetKeys objectAtIndex: 0];
    [targets removeObjectForKey: removeTargetKey];
    
    NSMutableArray *viewIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    
    if (targetKeys.count <= 1) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:onFinishShowStepEvent body:@{@"finish": @YES}];
    }
    else {
        [self.bridge.eventDispatcher sendDeviceEventWithName:onShowSequenceStepEvent body:@{@"next_step": @YES}];
    }
    
    for (NSString *view in [targets allKeys]) {
        [viewIds addObject: [NSNumber numberWithLongLong:[view longLongValue]]];
        [props setObject:(NSDictionary *)[targets objectForKey: view] forKey:view];
    }
    
    if ([viewIds count] > 0) {
        [self ShowSequence:viewIds props:props];
    }
}

RCT_EXPORT_METHOD(ShowFor:(nonnull NSNumber *)view props:(NSDictionary *)props)
{
    MaterialShowcase *materialShowcase = [self generateMaterialShowcase:view props:props];
    
    [materialShowcase showWithAnimated:true completion:^() {
        [self.bridge.eventDispatcher sendDeviceEventWithName:onStartShowStepEvent body:@{@"start_step": @YES}];
    }];
}

- (MaterialShowcase *)generateMaterialShowcase:(NSNumber *)view props:(NSDictionary *)props {
    
    MaterialShowcase *materialShowcase = [[MaterialShowcase alloc] init];
    UIView *target = [self.bridge.uiManager viewForReactTag: view];
    
    NSString *primaryText = [props objectForKey: @"title"];
    NSString *secondaryText = [props objectForKey: @"description"];
    
    // Background
    UIColor *backgroundPromptColor;
    NSString *backgroundPromptColorValue = [props objectForKey:@"backgroundPromptColor"];
    if (backgroundPromptColorValue != nil) {
        backgroundPromptColor = [self colorWithHexString: backgroundPromptColorValue];
    }
    if (backgroundPromptColor != nil) {
        [materialShowcase setBackgroundColor: backgroundPromptColor];
    }
    
    if ([props objectForKey:@"outerCircleAlpha"] != nil) {
        float backgroundPrompAlphaValue = [[props objectForKey:@"outerCircleAlpha"] floatValue];
        if (backgroundPrompAlphaValue >= 0.0 && backgroundPrompAlphaValue <= 1.0) {
            [materialShowcase setBackgroundPromptColorAlpha:backgroundPrompAlphaValue];
        }
    }
    
    // Target
    UIColor *targetTintColor;
    UIColor *targetHolderColor;
    
    NSString *targetTintColorValue = [props objectForKey:@"outerCircleColor"];
    if (targetTintColorValue != nil) {
        targetTintColor = [self colorWithHexString: targetTintColorValue];
    }
    NSString *targetHolderColorValue = [props objectForKey:@"targetHolderColor"];
    if (targetHolderColorValue != nil) {
        targetHolderColor = [self colorWithHexString: targetHolderColorValue];
    }
    
    if (targetTintColor != nil) {
        target.tintColor = targetTintColor;
        [materialShowcase setTargetTintColor: targetTintColor];
    } if (targetHolderColor != nil) {
        [materialShowcase setTargetHolderColor: targetHolderColor];
    }

    if ([[props objectForKey:@"transparentTarget"] boolValue] != nil) {
      BOOL *transparentTarget = [[props objectForKey:@"transparentTarget"] boolValue];
      [materialShowcase setTargetTran: transparentTarget];
    }
    
    if ([props objectForKey:@"targetRadius"] != nil) {
        float targetHolderRadiusValue = [[props objectForKey:@"targetRadius"] floatValue];
        if (targetHolderRadiusValue >= 0) {
            [materialShowcase setTargetHolderRadius: targetHolderRadiusValue];
        } else {
          [materialShowcase setTargetHolderRadius: 60];
        }
    } else {
      [materialShowcase setTargetHolderRadius: 60];
    }
    
    BOOL *isTapRecognizerForTagretViewValue = [[props objectForKey:@"isTapRecognizerForTagretView"] boolValue];
    if (isTapRecognizerForTagretViewValue == TRUE) {
        [materialShowcase setIsTapRecognizerForTagretView:TRUE];
    }
    
    // Text
    UIColor *primaryTextColor;
    UIColor *secondaryTextColor;
    //    showcase.primaryTextFont = UIFont.boldSystemFont(ofSize: primaryTextSize)
    //    showcase.secondaryTextFont = UIFont.systemFont(ofSize: secondaryTextSize)
    
    NSString *primaryTextColorValue = [props objectForKey:@"titleTextColor"];
    if (primaryTextColorValue != nil) {
        primaryTextColor = [self colorWithHexString:primaryTextColorValue];
    }
    
    NSString *secondaryTextColorValue = [props objectForKey:@"descriptionTextColor"];
    if (secondaryTextColorValue != nil) {
        secondaryTextColor = [self colorWithHexString:secondaryTextColorValue];
    }
    
    [materialShowcase setPrimaryText: primaryText];
    [materialShowcase setSecondaryText: secondaryText];
    
    if (primaryTextColor != nil) {
        [materialShowcase setPrimaryTextColor: primaryTextColor];
    } if (secondaryTextColor != nil) {
        [materialShowcase setSecondaryTextColor: secondaryTextColor];
    }

    if ([props objectForKey:@"titleTextSize"] != nil) {
      float primaryTextSizeValue = [[props objectForKey:@"titleTextSize"] floatValue];
      [materialShowcase setPrimaryTextSize: primaryTextSizeValue];
    } else {
      [materialShowcase setPrimaryTextSize: 20];
    }

    if ([props objectForKey:@"descriptionTextSize"] != nil) {
      float secondaryTextSizeValue = [[props objectForKey:@"descriptionTextSize"] floatValue];
      [materialShowcase setSecondaryTextSize: secondaryTextSizeValue];
    } else {
      [materialShowcase setSecondaryTextSize: 10]; 
    }
    
    NSString *primaryTextAlignmentValue = [props objectForKey:@"titleTextAlignment"];
    NSString *secondaryTextAlignmentValue = [props objectForKey:@"descriptionTextAlignment"];
    if (primaryTextAlignmentValue != nil) {
        NSTextAlignment* primaryTextAlign = [self getTextAlignmentByString:primaryTextAlignmentValue];
        [materialShowcase setSecondaryTextAlignment: primaryTextAlign];
    } if (secondaryTextAlignmentValue != nil) {
        NSTextAlignment* secondaryTextAlign = [self getTextAlignmentByString:secondaryTextAlignmentValue];
        [materialShowcase setSecondaryTextAlignment: secondaryTextAlign];
    }
    
    // Button
    if ([props objectForKey:@"buttonVisable"] != nil){
        BOOL *isButtonVisable = [[props objectForKey:@"buttonVisable"] boolValue];
        if (isButtonVisable) {
            if ([props objectForKey:@"buttonText"] != nil){
                NSString *buttonText = [props objectForKey: @"buttonText"];
                [materialShowcase setButtonText: buttonText];
            }
            if ([props objectForKey:@"buttonTextSize"] != nil){
                float buttonTextSize = [[props objectForKey:@"buttonTextSize"] floatValue];
                [materialShowcase setButtonTextSize: buttonTextSize];
            }
            if ([props objectForKey:@"buttonTextColor"] != nil){
                NSString *buttonTextColor = [props objectForKey: @"buttonTextColor"];
                [materialShowcase setButtonTextColor: [self colorWithHexString:buttonTextColor]];
            }
            if ([props objectForKey:@"buttonBGColor"] != nil){
                NSString *buttonBGColor = [props objectForKey: @"buttonBGColor"];
                [materialShowcase setButtonBGColor: [self colorWithHexString:buttonBGColor]];
            }
            if ([props objectForKey:@"buttonRadius"] != nil){
                float buttonRadius = [[props objectForKey:@"buttonRadius"] floatValue];
                [materialShowcase setButtonRadius: buttonRadius];
            }
        } else {
            [materialShowcase setButtonVisable: false];
        }
    } else {
        if ([props objectForKey:@"buttonText"] != nil){
            NSString *buttonText = [props objectForKey: @"buttonText"];
            [materialShowcase setButtonText: buttonText];
        }
        if ([props objectForKey:@"buttonTextSize"] != nil){
            float buttonTextSize = [[props objectForKey:@"buttonTextSize"] floatValue];
            [materialShowcase setButtonTextSize: buttonTextSize];
        }
        if ([props objectForKey:@"buttonTextColor"] != nil){
            NSString *buttonTextColor = [props objectForKey: @"buttonTextColor"];
            [materialShowcase setButtonTextColor: [self colorWithHexString:buttonTextColor]];
        }
        if ([props objectForKey:@"buttonBGColor"] != nil){
            NSString *buttonBGColor = [props objectForKey: @"buttonBGColor"];
            [materialShowcase setButtonBGColor: [self colorWithHexString:buttonBGColor]];
        }
        if ([props objectForKey:@"buttonRadius"] != nil){
            float buttonRadius = [[props objectForKey:@"buttonRadius"] floatValue];
            [materialShowcase setButtonRadius: buttonRadius];
        }
    }
    
    // Animation
    float aniComeInDurationValue = [[props objectForKey:@"aniComeInDuration"] floatValue]; // second unit
    float aniGoOutDurationValue = [[props objectForKey:@"aniGoOutDuration"] floatValue]; // second unit
    if (aniGoOutDurationValue > 0) {
        [materialShowcase setAniComeInDuration: aniComeInDurationValue];
    } if (aniGoOutDurationValue > 0) {
        [materialShowcase setAniGoOutDuration: aniGoOutDurationValue];
    }
    
    UIColor *aniRippleColor;
    NSString *aniRippleColorValue = [props objectForKey:@"aniRippleColor"];
    if (aniRippleColorValue != nil) {
        aniRippleColor = [self colorWithHexString: aniRippleColorValue];
    } if (aniRippleColor != nil) {
        [materialShowcase setAniRippleColor: aniRippleColor];
    }
    
    
    if ([props objectForKey:@"aniRippleAlpha"] != nil) {
        float aniRippleAlphaValue = [[props objectForKey:@"aniRippleAlpha"] floatValue];
        if (aniRippleAlphaValue >= 0.0 && aniRippleAlphaValue <= 1.0) {
            [materialShowcase setAniRippleAlpha: aniRippleAlphaValue];
        }
    }
    
    float aniRippleScaleValue = [[props objectForKey:@"aniRippleScale"] floatValue];
    if (aniRippleScaleValue > 0) {
        [materialShowcase setAniRippleScale:aniRippleScaleValue];
    }
    
    [materialShowcase setTargetViewWithView: target];
    [materialShowcase setDelegate: self];
    
    return materialShowcase;
}

RCT_EXPORT_METHOD(ShowViewPartition)
{
    [ViewPartition showViewPartition];
}

RCT_EXPORT_METHOD(HideViewPartition)
{
    [ViewPartition hideViewPartition];
}

@end
