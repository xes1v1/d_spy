//
//  DSpyPlugin+Capture.h
//  d_spy
//
//  Created by whqfor on 2020/12/7.
//

#import "DSpyPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSpyPlugin (Capture)

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
- (UIImage *)imageWithScreenshot;

/**
 *  返回截取到的图片的base64编码
 *
 *  @return NSString *
 */
- (NSString *)base64WithScreenshot;
 
/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
- (NSData *)dataWithScreenshotInPNGFormat;

@end

NS_ASSUME_NONNULL_END
