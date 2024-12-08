package com.example.photo_get_method;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import androidx.annotation.NonNull;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_METHOD = "com.karthikayanApps/methods";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_METHOD)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getImages")) {
                                String name = call.argument("name");
                                result.success(getListOfApps(name));
                                return;
                            }
                            result.notImplemented();
                        }
                );
    }

    //-------------------------------------------------------
    ArrayList<byte[]> images = new ArrayList<>();
    boolean gotResult = true;
    // if any error it return Map<true, ArrayList<byte[1] = 0>>
    private Map<Boolean, ArrayList<byte[]>> getListOfApps(String name) {
        Map<Boolean, ArrayList<byte[]>> resultMap =  new HashMap<>();
        if(gotResult && images.size() == 0){
            new doIT().execute(name);
            gotResult = false;
            resultMap.clear();
            resultMap.put(false, images);
            return resultMap;
        } else if(images.size() == 0){
            resultMap.clear();
            resultMap.put(false, images);
            return resultMap;
        } else{
            gotResult = true;
            resultMap.clear();
            ArrayList<byte[]> al = new ArrayList<>();
            al.addAll(images);
            resultMap.put(true, al);
            images.clear();
            return resultMap;
        }
    }
    //-------------------------------------------------------
    public class doIT extends AsyncTask<String,Void,Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }
        String html;
        @Override
        protected Void doInBackground(String... name) {
            try {
                Document document = Jsoup.connect("https://www.google.com/search?tbm=isch&q="+name[0]).get();
                Log.e("FirebaseToken-",""+document.html());
                html = document.html();
                Elements e = document.select(".DS1iW");
                images = getReturnData(e);
                if(images.size() == 0){
                    throw new IOException();
                }
            } catch (Exception e) {
                images.clear();
                images.add(new byte[1]);
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void unused) {
            super.onPostExecute(unused);
        }
    }

    private ArrayList<byte[]> getReturnData(Elements elements){
        ArrayList<byte[]> al = new ArrayList<>();
        for (int i = 0; i < elements.size(); i++) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            Bitmap bitmap = downloadImage(elements.get(i).attr("src"));
            if(bitmap == null){
                al.clear();
                return al;
            }else{
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
                byte[] bytesArray = stream.toByteArray();
                bitmap.recycle();
                al.add(bytesArray);
            }
        }
        return al;
    }
    private Bitmap downloadImage(String imageUrl) {
        try {
            InputStream inputStream = new URL(imageUrl).openStream();
            return BitmapFactory.decodeStream(inputStream);
        } catch (IOException e) {
            return null;
        }
    }
    //----image generation over--------------------------------------------------------
}