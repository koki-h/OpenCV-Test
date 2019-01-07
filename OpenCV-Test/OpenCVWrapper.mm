//
//  OpenCVWrapper.m
//  OpenCV-Test
//
//  Created by koki on 2019/01/02.
//  Copyright © 2019 koki. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/highgui/highgui_c.h>

#import "OpenCVWrapper.h"
@interface
OpenCVWrapper() <CvVideoCameraDelegate> {
    CvVideoCamera *cvCamera;
}
- (cv::Mat) binarizeByLightness:(cv::Mat)src l_threshold:(int) l_threshold;
- (cv::Mat) drawContours:(cv::Mat)mask canvas:(cv::Mat)canvas;
@end

@implementation OpenCVWrapper

- (void)processImage:(cv::Mat &)image {
    cv::Mat image_copy;
    int l_threshold = [[_param objectForKey: @"l_threshold"] intValue];
    bool mode_binalized = [[_param objectForKey:@"mode_binalized"] boolValue];
    image_copy = [self binarizeByLightness:image l_threshold:l_threshold];
    if (mode_binalized) {
        cv::cvtColor(image_copy, image, CV_BGR2BGRA); //二値化した白黒画像を表示
    } else {
        // しきい値の境界線を描画して表示
        image = [self drawContours:image_copy canvas:image];
        cv::cvtColor(image, image, CV_BGR2BGRA);
    }
}

- (void) createCameraWithParentView:(UIImageView*) parentView {
    cvCamera = [[CvVideoCamera alloc] initWithParentView:parentView];
    cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    cvCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    cvCamera.defaultFPS = 30;
    cvCamera.grayscaleMode = NO;
    cvCamera.delegate = self;
}

- (void) start{
    [cvCamera start];
}

- (void) toggleCameraPosition {
    [cvCamera switchCameras];
}

- (cv::Mat) drawContours:(cv::Mat)mask  canvas:(cv::Mat)canvas
{
    //cv::Mat dst(mask.rows,mask.cols,CV_8UC1); // 結果保存用
    std::vector< std::vector<cv::Point> > contours;
    cv::findContours(mask, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    if (contours.size() > 1) {
        cv::drawContours(canvas, contours, -1, cv::Scalar(255),1);
    }
    return canvas;
}

- (cv::Mat) binarizeByLightness:(cv::Mat)src l_threshold:(int)l_threshold
{
    
    cv::Mat mid;
    cv::cvtColor(src, mid, CV_BGR2HLS);
    cv::Mat dst(src.rows,src.cols,CV_8UC1); // 結果保存用
    for (int y=0; y<dst.rows; y++) {
        for (int x=0; x < dst.cols; x++) {
            int index = (int) mid.step * y + (x * 3);
            int dst_index = (int) dst.step * y + x;
            int l = mid.data[index+1];
            if (l > l_threshold) {
                dst.data[dst_index] = 255;
            } else {
                dst.data[dst_index] = 0;
            }
        }
    }
    return dst;
}

@end
