package com.yourcompany.WorkoutTracker;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.MethodCall;

public class MainActivity extends FlutterActivity {

    private SQLiteQueryExecutor queryExecutor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String DB_CHANNEL = "database";
        String ANDROID_CHANNEL = "android"; // For native Android things such as Intents (or getting battery life)

        new FlutterMethodChannel(getFlutterView(), DB_CHANNEL).setMethodCallHandler(new FlutterMethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, FlutterMethodChannel.Response response) {
                switch (methodCall.method) {
                    case "initDB":
                        initDB();
                        response.success("");
                        break;
                    case "query":
                        queryExecutor.rawQuery((String) methodCall.arguments, response);
                        break;
                    case "transaction":
                        queryExecutor.runTransaction((String) methodCall.arguments, response);
                        break;
                }
            }
        });

        new FlutterMethodChannel(getFlutterView(), ANDROID_CHANNEL).setMethodCallHandler(new FlutterMethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, FlutterMethodChannel.Response response) {
                switch (methodCall.method) {
                    case "openURL":
                        Uri uri = Uri.parse((String) methodCall.arguments);
                        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                        startActivity(intent);
                        break;
                }
            }
        });
    }

    private void initDB() {
        queryExecutor = new SQLiteQueryExecutor(getApplicationContext());
    }
}

