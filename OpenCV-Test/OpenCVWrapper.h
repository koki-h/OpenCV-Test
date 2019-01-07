//
//  OpenCVWrapper.h
//  OpenCV-Test
//
//  Created by koki on 2019/01/02.
//  Copyright © 2019 koki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
@property NSDictionary *param;
- (void) createCameraWithParentView:(UIImageView*) parentView;
- (void) start;
- (void) toggleCameraPosition;
@end

NS_ASSUME_NONNULL_END
