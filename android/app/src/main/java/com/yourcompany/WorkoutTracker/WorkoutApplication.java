package com.yourcompany.WorkoutTracker;

import com.facebook.stetho.Stetho;

import io.flutter.app.FlutterApplication;

/**
 * Created by silver_android on 3/12/2017.
 */

public class WorkoutApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Stetho.initializeWithDefaults(this);
    }
}
