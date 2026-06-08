package com.stormunblessed

import android.content.Context
import com.lagradost.cloudstream3.plugins.CloudstreamPlugin
import com.lagradost.cloudstream3.plugins.Plugin

@CloudstreamPlugin
class Animeav1Plugin : Plugin() {
    override fun load(context: Context) {
        registerMainAPI(Animeav1())
    }
}
