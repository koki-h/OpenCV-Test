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
    int slider_value = [[_param objectForKey: @"slider_value"] intValue];
    bool filter_on = [[_param objectForKey:@"filter_on"] boolValue];
    if (filter_on) {
//        image = [self filterCanny:image slider_value:slider_value];            //Canny境界検出
        image = [self filterCannyOverlay:image slider_value:slider_value];         //Cannyで検出した境界を元画像に重ねる
//        image = [self filterLightnessBinalized:image slider_value:slider_value]; //明るさによる二値化
//        image = [self filterLightnessContour:image slider_value:slider_value];   //明るさによって二値化し、境界を描画
//        image = [self filterInRange:image];
    }
}
- (cv::Mat) filterInRange: (cv::Mat) src {
    cv::Mat hls = cv::Mat(src.rows , src.cols , CV_MAKETYPE(src.depth() , src.channels()));//;src.clone();
    cv::cvtColor(src , hls , CV_BGR2HLS);
    cv::Mat dst = hls.clone();
    cv::Scalar lower,upper;
    lower = cv::Scalar(0,2,2);
    upper = cv::Scalar(179,252,255);
    cv::inRange(hls , lower , upper , dst);

    return dst;
}

- (cv::Mat) filterLightnessContour: (cv::Mat) src slider_value: (int) slider_value {
    cv::Mat dst;
    int l_threshold = slider_value;
    dst = [self binarizeByLightness:src l_threshold:l_threshold];
    dst = [self drawContours:dst canvas:src];
    return dst;
}

- (cv::Mat) filterLightnessBinalized: (cv::Mat) src slider_value: (int) slider_value {
    int l_threshold = slider_value;
    cv::Mat dst;
    dst = [self binarizeByLightness:src l_threshold:l_threshold];
    return dst;
}

- (cv::Mat) filterCannyOverlay: (cv::Mat) src slider_value: (int) slider_value {
    cv::Mat src2,dst;
    src2 = [self filterCanny:src slider_value:slider_value];
    cv::cvtColor(src2, src2, CV_GRAY2BGRA);
    cv::resize(src2, src2, src.size());
    dst = [self overlay:src layer:src2 color:cv::Scalar(0,0,0)];
    return dst;
}

- (cv::Mat) overlay: (cv::Mat) back layer:(cv::Mat) layer color:(cv::Scalar) color {
    //layerの0である画素はbackを残し、それ以外はcolorの色で上書きする
    //backもlayerもBGRA画像で、同じサイズである必要がある
    cv::Mat dst = back;
    for(int y = 0; y < back.rows; y++ ){
        for (int x = 0; x < back.cols; x++){
            uchar cell_color[layer.channels()];
            unsigned long cell_index = y * layer.step + x * layer.elemSize();
            for(int c = 0; c < layer.channels(); ++c){
                cell_color[c] = layer.data[ cell_index + c ] ;
            }
            if (cell_color[0] != 0 && cell_color[1] != 0 && cell_color[2] != 0){
                for(int c = 0; c < 3; ++c){
                    dst.data[cell_index + c] = color[c];
                }
            }
        }
    }
    return dst;
}

- (cv::Mat) filterCanny: (cv::Mat) src slider_value: (int) slider_value {
    cv::Mat dst;
    cv::cvtColor(src, dst, cv::COLOR_BGRA2GRAY);
    int count_pyr =((float(slider_value)/255.0) * 5);
    printf("count_pyr:%d\n",count_pyr);
    for (int i = 0; i < count_pyr; i++){
        cv::pyrDown( dst, dst );
    }
    cv::Canny(dst, dst, 10, 100, 3, true);
    return dst;
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
        cv::drawContours(canvas, contours, -1, cv::Scalar(0,0,0),1);
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
