// mostly copied from:
// https://github.com/GoogleChrome/custom-tabs-client/blob/master/demos/src/main/java/org/chromium/customtabsdemos/CustomTabActivityHelper.java

package com.customtabplugin.helpers;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import androidx.browser.customtabs.CustomTabsClient;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsServiceConnection;
import androidx.browser.customtabs.CustomTabsSession;
import android.text.TextUtils;

import com.customtabplugin.ChromeCustomTabPlugin;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * This is a helper class to manage the connection to the Custom Tabs Service.
 */
public class CustomTabServiceHelper implements ServiceConnectionCallback {

    public static final String TAG = ChromeCustomTabPlugin.TAG + ".CustomTabServiceHelper";
    private String mPackageNameToBind;
    private CustomTabsSession mCustomTabsSession;
    private CustomTabsClient mClient;
    private CustomTabsServiceConnection mConnection;
    private ConnectionCallback mConnectionCallback;

    public CustomTabServiceHelper(Context context){
        mPackageNameToBind = CustomTabsHelper.getPackageNameToUse(context);
    }

    public boolean isAvailable(){
        return !TextUtils.isEmpty(mPackageNameToBind);
    }

    public void useChrome(Context context) throws CustomTabsHelper.InvalidPackageException {
        mPackageNameToBind = CustomTabsHelper.useChrome(context);
    }

    public void setPackageNameToBind(String packageName, Context context) throws CustomTabsHelper.InvalidPackageException {
        CustomTabsHelper.setPackageNameToUse(packageName, context);
        mPackageNameToBind = packageName;
    }

    /**
     * Unbinds the Activity from the Custom Tabs Service.
     * @param activity the activity that is connected to the service.
     */
    public boolean unbindCustomTabsService(Activity activity) {
        if (mConnection == null) return false;
        activity.unbindService(mConnection);
        mClient = null;
        mCustomTabsSession = null;
        mConnection = null;
        return true;
    }

    /**
     * Creates or retrieves an exiting CustomTabsSession.
     *
     * @return a CustomTabsSession.
     */
    public CustomTabsSession getSession() {
        if (mClient == null) {
            mCustomTabsSession = null;
        } else if (mCustomTabsSession == null) {
            mCustomTabsSession = mClient.newSession(null);
        }
        return mCustomTabsSession;
    }

    /**
     * Register a Callback to be called when connected or disconnected from the Custom Tabs Service.
     * @param connectionCallback
     */
    public void setConnectionCallback(ConnectionCallback connectionCallback) {
        this.mConnectionCallback = connectionCallback;
    }

    private final Set<ServiceConnectionCallback> onConnectOnce = new HashSet<>();

    /**
     * Binds the Activity to the Custom Tabs Service.
     * @param activity the activity to be bound to the service.
     * @param callback
     */
    public void bindCustomTabsService(Activity activity, final BooleanCallback callback) {
        if (mClient != null) {
            Log.i(TAG, "bindCustomTabsService: already bound");
            callback.done(true);
            return;
        }

        if (mPackageNameToBind == null)
        {
            Log.w(TAG, "bindCustomTabsService: no package name specified");
            callback.done(false);
            return;
        };

        this.onConnectOnce.add(new ServiceConnectionCallback()
        {
            public void onServiceConnected(CustomTabsClient client)
            {
                callback.done(client!=null);
            }

            public void onServiceDisconnected()
            {
                callback.done(false);
            }
        });

        mConnection = new ServiceConnection(this);
        CustomTabsClient.bindCustomTabsService(activity, mPackageNameToBind, mConnection);
    }

    /**
     * @see {@link CustomTabsSession#mayLaunchUrl(Uri, Bundle, List)}.
     * @return true if call to mayLaunchUrl was accepted.
     */
    public boolean mayLaunchUrl(Uri uri, Bundle extras, List<Bundle> otherLikelyBundles) {
        if (mClient == null) return false;

        CustomTabsSession session = getSession();
        if (session == null) return false;

        return session.mayLaunchUrl(uri, extras, otherLikelyBundles);
    }

    @Override
    public void onServiceConnected(CustomTabsClient client) {
        Log.w(TAG, "onServiceConnected: " + client);
        mClient = client;
        if (mConnectionCallback != null) mConnectionCallback.onCustomTabsConnected();
        for (ServiceConnectionCallback cb : this.onConnectOnce)
            cb.onServiceConnected(client);
        this.onConnectOnce.clear();
    }

    @Override
    public void onServiceDisconnected() {
        Log.w(TAG, "onServiceDisconnected");
        mClient = null;
        mCustomTabsSession = null;
        if (mConnectionCallback != null) mConnectionCallback.onCustomTabsDisconnected();
        for (ServiceConnectionCallback cb : this.onConnectOnce)
            cb.onServiceDisconnected();
        this.onConnectOnce.clear();
    }

    public CustomTabsClient getClient() {
        return mClient;
    }

    /**
     * A Callback for when the service is connected or disconnected. Use those callbacks to
     * handle UI changes when the service is connected or disconnected.
     */
    public interface ConnectionCallback {
        /**
         * Called when the service is connected.
         */
        void onCustomTabsConnected();

        /**
         * Called when the service is disconnected.
         */
        void onCustomTabsDisconnected();
    }
}
