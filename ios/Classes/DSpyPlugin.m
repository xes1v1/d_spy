#import "DSpyPlugin.h"
#import "DSpyPlugin+Capture.h"

typedef NSString *DSpyMethodChannelName;
DSpyMethodChannelName const DSpyPlatformVersion = @"getPlatformVersion";
DSpyMethodChannelName const  DSpySendScreenShotActionToNative = @"spySendScreenShotActionToNative";
DSpyMethodChannelName const  DSpyReceiveScreenShotFromNative = @"spyReceiveScreenShotFromNative";

@interface DSpyPlugin ()
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@end

@implementation DSpyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"d_spy"
              binaryMessenger:registrar.messenger];
    DSpyPlugin* instance = [DSpyPlugin sharedInstance];
    instance.methodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([DSpyPlatformVersion isEqualToString:call.method]) {
      NSString *platform = [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
      result(platform);
  } if ([DSpySendScreenShotActionToNative isEqualToString:call.method]) {
      // 去截图
      
      NSDictionary *argu = call.arguments;
      NSString *base64 = [self base64WithScreenshot];
      if (!base64) {
          return;
      }
      NSDictionary *dict = @{@"target": argu[@"target"],
                             @"imageData": [@"data:image/png;base64," stringByAppendingString:base64]
                            };
      [self sendScreenshotToFlutter:dict];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)sendScreenshotToFlutter:(NSDictionary *)screenshot
{
    NSLog(@"sendScreenshotToFlutter base64");
    [self invokeMethod:DSpyReceiveScreenShotFromNative arguments:screenshot result:nil];
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback
{
    DSpyPlugin *instance = [DSpyPlugin sharedInstance];
    [instance.methodChannel invokeMethod:method arguments:arguments result:callback];
}

+ (DSpyPlugin *)sharedInstance
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    return _instance;
}

@end
