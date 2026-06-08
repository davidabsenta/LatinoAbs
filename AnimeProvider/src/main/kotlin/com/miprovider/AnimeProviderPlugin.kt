package com.miprovider

import android.content.Context
import com.lagradost.cloudstream3.plugins.CloudstreamPlugin
import com.lagradost.cloudstream3.plugins.Plugin

@CloudstreamPlugin
class AnimeProviderPlugin : Plugin() {
    override fun load(context: Context) {
        registerMainAPI(AnimeProvider())
    }
}
