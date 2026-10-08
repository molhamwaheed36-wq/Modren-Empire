package com.molham.modrenempire

import android.app.Activity
import android.os.Bundle
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient

class MainActivity : Activity() {
    private lateinit var web: WebView
    private val lan = LanBridge()

    override fun onCreate(state: Bundle?) {
        super.onCreate(state)
        web = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.allowFileAccess = true
            settings.allowContentAccess = true
            webViewClient = WebViewClient()
            webChromeClient = WebChromeClient()
            addJavascriptInterface(lan, "ModrenLAN")
        }
        setContentView(web)
        web.loadUrl("file:///android_asset/game/index.html")
    }

    override fun onDestroy() {
        lan.stop()
        web.destroy()
        super.onDestroy()
    }

    @Deprecated("Android back navigation is intentionally owned by the game UI")
    override fun onBackPressed() { }
}
