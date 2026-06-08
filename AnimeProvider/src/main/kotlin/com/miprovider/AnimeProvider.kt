package com.miprovider

import com.lagradost.cloudstream3.*
import com.lagradost.cloudstream3.utils.ExtractorLink
import com.lagradost.cloudstream3.utils.loadExtractor

class AnimeProvider : MainAPI() {
    override var mainUrl = "https://example.com"
    override var name = "AnimeProvider"
    override var lang = "es"
    override val hasMainPage = true
    override val hasChromecastSupport = true
    override val hasDownloadSupport = true
    override val supportedTypes = setOf(
        TvType.Anime,
        TvType.Movie,
    )

    override suspend fun getMainPage(page: Int, request: MainPageRequest): HomePageResponse? {
        val items = ArrayList<HomePageList>()
        
        val home = listOf(
            newAnimeSearchResponse("Ejemplo Anime", "$mainUrl/anime/1", TvType.Anime) {
                this.posterUrl = "https://example.com/poster.jpg"
            }
        )
        
        items.add(HomePageList("Recientes", home))
        return newHomePageResponse(items)
    }

    override suspend fun search(query: String): List<SearchResponse> {
        return listOf(
            newAnimeSearchResponse("Resultado: $query", "$mainUrl/search?q=$query", TvType.Anime)
        )
    }

    override suspend fun load(url: String): LoadResponse? {
        val episodes = listOf(
            newEpisode("$url/ep1") {
                this.name = "Episodio 1"
                this.episode = 1
            }
        )
        
        return newTvSeriesLoadResponse(
            "Título del Anime",
            url,
            TvType.Anime,
            episodes,
        ) {
            this.posterUrl = "https://example.com/poster.jpg"
            this.plot = "Descripción del anime"
        }
    }

    override suspend fun loadLinks(
        data: String,
        isCasting: Boolean,
        subtitleCallback: (SubtitleFile) -> Unit,
        callback: (ExtractorLink) -> Unit
    ): Boolean {
        return true
    }
}
