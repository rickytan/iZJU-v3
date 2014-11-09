//
//  RAutoTextView.h
//  RAutoAdjust
//
//  Created by ricky on 13-3-22.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !__has_feature(objc_arc)
#   ifndef RARelease
#       define RARelease(a) ([a release])
#   endif

#   ifndef RAAutorelease
#       define RAAutorelease(a) ([a autorelease])
#   endif
#else
#   ifndef RARelease
#       define RARelease(a) {}
#   endif

#   ifndef RAAutorelease
#       define RAAutorelease(a) (a)
#   endif
#endif

@interface RAutoTextView : UITextView
@property (nonatomic, assign) CGFloat visibleLinesWhenKeyboardOverlay;   // Default 2
@end
