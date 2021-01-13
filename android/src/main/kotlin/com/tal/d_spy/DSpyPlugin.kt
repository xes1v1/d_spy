package com.tal.d_spy

import android.app.Activity
import android.app.Application
import android.graphics.Bitmap
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import androidx.annotation.NonNull
import com.yorhp.recordlibrary.OnScreenShotListener
import com.yorhp.recordlibrary.ScreenShotUtil
import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.HashMap

/** DSpyPlugin */
class DSpyPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "d_spy")
    channel.setMethodCallHandler(this)
    var context = flutterPluginBinding.applicationContext as Application
    context.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
      override fun onActivityPaused(activity: Activity) {
      }

      override fun onActivityStarted(activity: Activity) {
      }

      override fun onActivityDestroyed(activity: Activity) {
      }

      override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
      }

      override fun onActivityStopped(activity: Activity) {
      }

      override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        this@DSpyPlugin.activity = activity
      }

      override fun onActivityResumed(activity: Activity) {
        this@DSpyPlugin.activity = activity
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "spySendScreenShotActionToNative") {
      val arguments = call.arguments as Map<*, *>
      handleSpySendScreenShotActionToNative(arguments)
    } else {
      result.notImplemented()
    }
  }

  private fun handleSpySendScreenShotActionToNative(arguments: Map<*, *>?) {
    if (arguments == null) {
      return
    }
    val target: String = arguments["target"] as String
    if (TextUtils.isEmpty(target)) {
      return
    }
    if (activity is FlutterActivity || activity.parent is FlutterActivity) {
      SnapShotUtils.getImgBase64(activity, object : OnScreenShotListener {
        override fun screenShot() {
          val bitmap: Bitmap = ScreenShotUtil.getInstance().screenShot
          ScreenShotUtil.getInstance().destroy()
          var imgBase64 = SnapShotUtils.getImgBase64(bitmap)
          if (TextUtils.isEmpty(imgBase64)) {
            imgBase64 = ""
          } else {
            imgBase64 = "data:image/png;base64,$imgBase64"
          }
          spyReceiveScreenShotFromNative(target, imgBase64)
        }
      })
    } else {
      val bitmap: Bitmap = SnapShotUtils.takeScreenShot(activity)
      var imgBase64: String = SnapShotUtils.getImgBase64(bitmap)
      if (TextUtils.isEmpty(imgBase64)) {
        imgBase64 = ""
      } else {
        imgBase64 = "data:image/png;base64,$imgBase64"
      }
      spyReceiveScreenShotFromNative(target, imgBase64)
    }
  }

  private fun spyReceiveScreenShotFromNative(target: String, img: String) {
    Log.e("dstackspy", "spyReceiveScreenShotFromNative")
    val resultMap: HashMap<String?, Any?> = HashMap<String?, Any?>()
    resultMap["target"] = target
    resultMap["imageData"] = img
    channel.invokeMethod("spyReceiveScreenShotFromNative", resultMap)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
