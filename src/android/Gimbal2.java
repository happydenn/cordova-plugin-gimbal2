package io.hpd.cordova.gimbal2;

/*
 * Cordova Plugin - Gimba v2
 * Denny Tsai <happydenn@happydenn.net>
 */

import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.List;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.gimbal.android.Gimbal;
import com.gimbal.android.BeaconManager;
import com.gimbal.android.BeaconEventListener;
import com.gimbal.android.BeaconSighting;
import com.gimbal.android.Beacon;
import com.gimbal.android.PlaceEventListener;
import com.gimbal.android.PlaceManager;
import com.gimbal.android.Visit;


public class Gimbal2 extends CordovaPlugin {

    private CallbackContext gimbalCallbackContext;
    private SimpleDateFormat simpleDateFormat;

    private BeaconManager beaconManager;
    private BeaconEventListener beaconEventListener;

    private PlaceManager placeManager;
    private PlaceEventListener placeEventListener;

	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("initialize")) {
            if (args.length() != 1) return false;

            String apiKey = args.getString(0);
            Gimbal.setApiKey(cordova.getActivity().getApplication(), apiKey);

            if (gimbalCallbackContext == null) {
                gimbalCallbackContext = callbackContext;
            }

            if (simpleDateFormat == null) {
                simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
            }

            beaconEventListener = new BeaconEventListener() {
                @Override
                public void onBeaconSighting(BeaconSighting beaconSighting) {
                    Log.i("INFO", "onBeaconSighting: " + beaconSighting.toString());

                    Beacon beacon = beaconSighting.getBeacon();

                    JSONObject responseObject = new JSONObject();

                    try {
                        responseObject.put("event", "onBeaconSighting");
                        responseObject.put("RSSI", beaconSighting.getRSSI());
                        responseObject.put("datetime", simpleDateFormat.format(new Date(beaconSighting.getTimeInMillis())));
                        responseObject.put("beaconName", beacon.getName());
                        responseObject.put("beaconIdentifier", beacon.getIdentifier());
                        responseObject.put("beaconUniqueIdentifier", beacon.getUuid());
                        responseObject.put("beaconBatteryLevel", beacon.getBatteryLevel());
                        responseObject.put("beaconIconUrl", beacon.getIconURL());
                        responseObject.put("beaconTemperature", beacon.getTemperature());
                    } catch (JSONException e) {
                        Log.e("Error", e.getMessage(), e);
                    }

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, responseObject);
                    pluginResult.setKeepCallback(true);

                    gimbalCallbackContext.sendPluginResult(pluginResult);
                }
            };

            beaconManager = new BeaconManager();
            beaconManager.addListener(beaconEventListener);



            placeEventListener = new PlaceEventListener() {

                @Override
                public void onVisitStart (Visit visit) {
                    Log.i("INFO", "onVisitStart: " + visit.toString());

                    JSONObject responseObject = new JSONObject();

                    try {
                        responseObject.put("event", "onBeginVisit");
                        responseObject.put("visitId", visit.getVisitID());
                        responseObject.put("placeId", visit.getPlace().getIdentifier());
                        responseObject.put("placeName", visit.getPlace().getName());
                        responseObject.put("placeAttributes", visit.getPlace().getAttributes());
                    } catch (JSONException e) {
                        Log.e("Error", e.getMessage(), e);
                    }

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, responseObject);
                    pluginResult.setKeepCallback(true);

                    gimbalCallbackContext.sendPluginResult(pluginResult);
                }

                @Override
                public void onVisitEnd (Visit visit) {
                    Log.i("INFO", "onVisitStart: " + visit.toString());

                    JSONObject responseObject = new JSONObject();

                    try {
                        responseObject.put("event", "onEndVisit");
                        responseObject.put("visitId", visit.getVisitID());
                        responseObject.put("placeId", visit.getPlace().getIdentifier());
                        responseObject.put("placeName", visit.getPlace().getName());
                        responseObject.put("placeAttributes", visit.getPlace().getAttributes());
                    } catch (JSONException e) {
                        Log.e("Error", e.getMessage(), e);
                    }

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, responseObject);
                    pluginResult.setKeepCallback(true);

                    gimbalCallbackContext.sendPluginResult(pluginResult);
                }

                @Override
                public void onBeaconSighting(BeaconSighting beaconSighting, List<Visit> visits) {
                    for (Visit visit: visits) {
                        Beacon beacon = beaconSighting.getBeacon();

                        JSONObject responseObject = new JSONObject();

                        try {
                            responseObject.put("event", "onBeaconSightingForVisit");
                            responseObject.put("visitId", visit.getVisitID());
                            responseObject.put("placeId", visit.getPlace().getIdentifier());
                            responseObject.put("RSSI", beaconSighting.getRSSI());
                            responseObject.put("datetime", simpleDateFormat.format(new Date(beaconSighting.getTimeInMillis())));
                            responseObject.put("beaconName", beacon.getName());
                            responseObject.put("beaconIdentifier", beacon.getIdentifier());
                            responseObject.put("beaconUniqueIdentifier", beacon.getUuid());
                            responseObject.put("beaconBatteryLevel", beacon.getBatteryLevel());
                            responseObject.put("beaconIconUrl", beacon.getIconURL());
                            responseObject.put("beaconTemperature", beacon.getTemperature());
                        } catch (JSONException e) {
                            Log.e("Error", e.getMessage(), e);
                        }

                        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, responseObject);
                        pluginResult.setKeepCallback(true);

                        gimbalCallbackContext.sendPluginResult(pluginResult);

                    }
                }
            };

            placeManager = PlaceManager.getInstance();
            placeManager.addListener(placeEventListener);

            List<Visit> visits = placeManager.currentVisits();
            for (Visit visit: visits) {
                placeEventListener.onVisitStart(visit);
            }


            Gimbal.start();

            return true;
        }

        if (action.equals("startBeaconManager")) {
            if (beaconManager == null) return false;

            placeManager.startMonitoring();
            beaconManager.startListening();
            return true;
        }

        if (action.equals("stopBeaconManager")) {
            if (beaconManager == null) return false;

            placeManager.stopMonitoring();
            beaconManager.stopListening();
            return true;
        }

		return false;
	}
}
