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
@end

@implementation OpenCVWrapper

- (void)processImage:(cv::Mat &)image {
    cv::Mat image_copy;
    cv::cvtColor(image, image_copy, CV_BGRA2BGR);
    //invert imege
    cv::bitwise_not(image_copy, image_copy);
//    image_copy = [self thresholdByColor:image];
//    std::vector< std::vector<cv::Point> > contours;
//    cv::findContours(image_copy, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
//    cv::drawContours(image_copy, contours, 1, cv::Scalar(255), -1);
//
    cv::cvtColor(image_copy, image, CV_BGR2BGRA);
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

//+ (cv::Mat) thresholdByColor:(cv::Mat)src
//{
//    // 結果保存用
//    cv::Mat dst(src.rows,src.cols,CV_8UC1);
//
//    for (int y=0; y<dst.rows; y++) {
//        cv::Vec4b *s = src.ptr<cv::Vec4b>(y);
//        uchar *d = dst.ptr<uchar>(y);
//        for (int x=0; x < dst.cols; x++) {
//            int b = s[x][0],g = s[x][1],r = s[x][2];
//            d[x] = 255;
//            // 青いベルトの色の範囲は以下とする。
//            // 明るい青い部分；B>=200 & B>G+40 & B>R+50
//
//            if (b >= 200 && b > (g + 40) && b > (r + 50)){
//                d[x] = 0;
//            }
//            // 暗いベルトの部分；B<200 & B>=100 & B>G+35 & B>R+5
//            if (b < 200 && b >= 100 && b > (g + 35) && b > (r + 5)){
//                d[x] = 0;
//            }
//        }
//    }
//    return dst;
//}

@end
