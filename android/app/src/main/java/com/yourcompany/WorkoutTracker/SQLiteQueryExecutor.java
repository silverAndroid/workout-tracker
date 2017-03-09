package com.yourcompany.WorkoutTracker;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Base64;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;

import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.view.FlutterView;

/**
 * Created by silver_android on 05/03/17.
 */

public class SQLiteQueryExecutor extends SQLiteOpenHelper {

    private static final String DB_NAME = "workout_tracker";
    private static final int DB_VERSION = 1;
    private final FlutterView flutterView;
    private Charset utfset;
    private CharsetEncoder encoder;
    private CharsetDecoder decoder;

    public SQLiteQueryExecutor(Context context, FlutterView flutterView) {
        super(context, DB_NAME, null, DB_VERSION);
        this.flutterView = flutterView;

        this.flutterView.addOnBinaryMessageListenerAsync("query", rawQuery);
        utfset = Charset.forName("UTF-8");
        encoder = utfset.newEncoder();
        decoder = utfset.newDecoder();
    }

    @Override
    public void onCreate(SQLiteDatabase db) {

    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }

    public void rawQuery(String queryJSON, FlutterMethodChannel.Response response) {
        try {
            JSONObject queryObj = new JSONObject(queryJSON);
            String query = queryObj.getString("query");
            JSONArray paramsArray = queryObj.getJSONArray("params");
            String[] params = new String[paramsArray.length()];
            for (int i = 0, length = paramsArray.length(); i < length; i++) {
                params[i] = paramsArray.getString(i);
            }
            boolean write = queryObj.getBoolean("write");

            SQLiteDatabase database = write ? getWritableDatabase() : getReadableDatabase();
            Cursor cursor = database.rawQuery(query, params);
//            ByteBuffer responseBuffer = ByteBuffer.wrap(.getBytes());
            response.success(cursorToJSON(cursor).toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public final FlutterView.OnBinaryMessageListenerAsync rawQuery = new FlutterView.OnBinaryMessageListenerAsync() {
        @Override
        public void onMessage(FlutterView flutterView, ByteBuffer byteBuffer, FlutterView.BinaryMessageResponse binaryMessageResponse) {
            try {
                byteBuffer.flip();
                byte[] bytes = new byte[byteBuffer.remaining()];
                byteBuffer.get(bytes);
                CharBuffer buffer = decoder.decode(byteBuffer);
                JSONObject queryObj = new JSONObject(buffer.toString());
                String query = queryObj.getString("query");
                JSONArray paramsArray = queryObj.getJSONArray("params");
                String[] params = new String[paramsArray.length()];
                for (int i = 0, length = paramsArray.length(); i < length; i++) {
                    params[i] = paramsArray.getString(i);
                }
                boolean write = queryObj.getBoolean("write");

                SQLiteDatabase database = write ? getWritableDatabase() : getReadableDatabase();
                Cursor cursor = database.rawQuery(query, params);
                ByteBuffer responseBuffer = ByteBuffer.wrap(cursorToJSON(cursor).toString().getBytes());
                binaryMessageResponse.send(responseBuffer);
            } catch (JSONException | CharacterCodingException e) {
                e.printStackTrace();
            }
        }
    };

    private JSONArray cursorToJSON(Cursor cursor) throws JSONException {
        JSONArray cursorJSON = new JSONArray();
        if (cursor.moveToFirst()) {
            do {
                int numColumns = cursor.getColumnCount();
                JSONObject row = new JSONObject();
                for (int i = 0; i < numColumns; i++) {
                    String columnName = cursor.getColumnName(i);
                    if (columnName != null) {
                        Object val = null;
                        switch (cursor.getType(i)) {
                            case Cursor.FIELD_TYPE_INTEGER:
                                val = cursor.getInt(i);
                                break;
                            case Cursor.FIELD_TYPE_FLOAT:
                                val = cursor.getFloat(i);
                                break;
                            case Cursor.FIELD_TYPE_STRING:
                                val = cursor.getString(i);
                                break;
                            case Cursor.FIELD_TYPE_BLOB:
                                val = Base64.encodeToString(cursor.getBlob(i), Base64.DEFAULT);
                                break;
                        }

                        row.put(columnName, val);
                    }
                }
                cursorJSON.put(row);
            } while (cursor.moveToNext());
        }
        cursor.close();
        return cursorJSON;
    }
}
