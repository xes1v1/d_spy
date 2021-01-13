//
//  DSpyPlugin+Capture.m
//  d_spy
//
//  Created by whqfor on 2020/12/7.
//

#import "DSpyPlugin+Capture.h"

//#import <AssetsLibrary/AssetsLibrary.h>

@implementation DSpyPlugin (Capture)

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
- (UIImage *)imageWithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

/**
 *  返回截取到的图片的base64编码
 *
 *  @return NSString *
 */
- (NSString *)base64WithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    
    // 截图后保存到相册，需要目标工程增加存相册权限
//    ALAssetsLibrary * library = [ALAssetsLibrary new];
//    [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:nil];
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];;
}
 
/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
- (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
        
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
     
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    return UIImagePNGRepresentation(image);
}


@end
