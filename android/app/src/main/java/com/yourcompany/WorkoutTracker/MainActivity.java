package com.yourcompany.WorkoutTracker;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.MethodCall;

public class MainActivity extends FlutterActivity {

    private SQLiteQueryExecutor queryExecutor;
    private String DB_CHANNEL = "database";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new FlutterMethodChannel(getFlutterView(), DB_CHANNEL).setMethodCallHandler(new FlutterMethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, FlutterMethodChannel.Response response) {
                if (methodCall.method.equals("initDB")) {
                    initDB();
                    response.success("");
                } else if (methodCall.method.equals("query")) {
                    queryExecutor.rawQuery((String) methodCall.arguments, response);
                }
            }
        });
    }

    private void initDB() {
        queryExecutor = new SQLiteQueryExecutor(getApplicationContext());
    }
}

