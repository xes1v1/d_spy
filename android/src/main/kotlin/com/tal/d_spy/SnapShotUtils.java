package com.tal.d_spy;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.view.View;

import com.yorhp.recordlibrary.OnScreenShotListener;
import com.yorhp.recordlibrary.ScreenShotUtil;

import java.io.ByteArrayOutputStream;

public class SnapShotUtils {

    public static void getImgBase64(Activity activity, OnScreenShotListener onScreenShotListener) {
        ScreenShotUtil.getInstance().screenShot(activity, onScreenShotListener);
    }

    public static Bitmap takeScreenShot(Activity activity) {
        if (activity == null || activity.isFinishing()) {
            return null;
        }
        View view = activity.getWindow().getDecorView();
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();
        Bitmap bmp = view.getDrawingCache();
        int statusBarHeight = getStatusBarHeight(activity);
        int width = (int) getDeviceDisplaySize(activity)[0];
        int height = (int) getDeviceDisplaySize(activity)[1];
        Bitmap ret = Bitmap.createBitmap(bmp, 0, statusBarHeight, width, height - statusBarHeight);
        view.destroyDrawingCache();
        return ret;
    }

    public static String getImgBase64(Bitmap scrBmp) {
        if (scrBmp == null) {
            return "";
        }
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        scrBmp.compress(Bitmap.CompressFormat.PNG, 100, bos);
        byte[] bb = bos.toByteArray();
        String image = Base64.encodeToString(bb, Base64.NO_WRAP);
        return image;
    }

    public static float[] getDeviceDisplaySize(Context context) {
        Resources resources = context.getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();
        int width = dm.widthPixels;
        int height = dm.heightPixels;

        float[] size = new float[2];
        size[0] = width;
        size[1] = height;

        return size;
    }

    public static int getStatusBarHeight(Context context) {
        int height = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            height = context.getResources().getDimensionPixelSize(resourceId);
        }

        return height;
    }

    /**
     * Bitmap对象是否为空。
     */
    public static boolean isEmptyBitmap(Bitmap src) {
        return src == null || src.getWidth() == 0 || src.getHeight() == 0;
    }

}
