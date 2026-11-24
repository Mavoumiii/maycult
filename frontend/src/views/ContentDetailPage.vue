<script setup>
import { computed } from 'vue'
import { categoryLabels } from '../data/siteData.js'
import TextWithLinks from '../components/TextWithLinks.vue'

const props = defineProps({
  item: { type: Object, required: true },
})
const emit = defineEmits(['back'])

const title = computed(() => props.item.title || props.item.name || 'Détail du contenu')
const image = computed(() => props.item.image || props.item.imageUrl || '')
const isTressage = computed(() => title.value.toLowerCase().includes('tressage'))
const videoUrl = computed(() => props.item.videoUrl || props.item.youtubeUrl || props.item.mediaUrl || '')
const mediaEmbed = computed(() => {
  if (!videoUrl.value) return ''
  try {
    const url = new URL(videoUrl.value)
    if (url.protocol !== 'https:') return null
    const host = url.hostname.toLowerCase()
    let videoId = ''
    if (host === 'youtu.be') {
      videoId = url.pathname.slice(1).split('/')[0]
    } else if (['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtube-nocookie.com', 'www.youtube-nocookie.com'].includes(host)) {
      videoId = url.searchParams.get('v') || url.pathname.match(/^\/(?:embed|shorts)\/([^/]+)/)?.[1] || ''
    }
    if (/^[\w-]{11}$/.test(videoId)) {
      return { kind: 'video', url: `https://www.youtube-nocookie.com/embed/${videoId}` }
    }

    if (host === 'vimeo.com' || host.endsWith('.vimeo.com')) {
      const vimeoId = url.pathname.match(/\/(\d+)(?:\/|$)/)?.[1]
      if (vimeoId) return { kind: 'video', url: `https://player.vimeo.com/video/${vimeoId}` }
    }

    if (host === 'soundcloud.com' || host.endsWith('.soundcloud.com')) {
      return {
        kind: 'audio',
        url: `https://w.soundcloud.com/player/?url=${encodeURIComponent(url.toString())}&visual=false`,
      }
    }
    return null
  } catch {
    return null
  }
})
const location = computed(() => props.item.discoveryPlace || props.item.location || props.item.address || props.item.village || '')

function formatDate(value) {
  if (!value) return ''
  const date = new Date(`${value}T00:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
}

const eventDates = computed(() => {
  if (!props.item.start) return ''
  const start = formatDate(props.item.start)
  const end = formatDate(props.item.end)
  return end && end !== start ? `${start} – ${end}` : start
})
</script>

<template>
  <main class="page-shell content-detail-page p-3 p-md-4 p-lg-5">
    <div class="container">
      <button type="button" class="btn btn-outline-danger mb-4" @click="emit('back')">
        ← Retour
      </button>

      <article class="content-detail-article bg-white rounded-4 shadow-sm p-3 p-md-4 p-lg-5">
        <p v-if="item.category || item.theme || item.type" class="small text-secondary mb-2">
          {{ categoryLabels[item.category] || item.category || categoryLabels[item.theme] || item.theme }}<span v-if="(item.category || item.theme) && item.type"> · </span>{{ item.type }}
        </p>
        <h1 class="content-detail-title fw-bold mb-3">{{ title }}</h1>
        <p v-if="eventDates" class="text-secondary mb-2">{{ eventDates }}</p>
        <p v-if="location" class="text-secondary mb-4"><TextWithLinks :text="location" /></p>

        <img v-if="image" :src="image" :alt="title" class="content-detail-image rounded-3 mb-4" :class="{ 'content-detail-image--tressage': isTressage }">

        <iframe
          v-if="mediaEmbed"
          :src="mediaEmbed.url"
          :title="`${mediaEmbed.kind === 'audio' ? 'Audio' : 'Vidéo'} : ${title}`"
          :class="mediaEmbed.kind === 'audio' ? 'content-detail-audio-frame rounded-3 mb-4' : 'content-detail-video rounded-3 mb-4'"
          :allow="mediaEmbed.kind === 'audio' ? 'autoplay' : 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'"
          referrerpolicy="strict-origin-when-cross-origin"
          allowfullscreen
        ></iframe>
        <video
          v-else-if="videoUrl && item.mediaType?.startsWith('video/')"
          :src="videoUrl"
          class="content-detail-video rounded-3 mb-4"
          controls
          playsinline
        ></video>
        <audio
          v-else-if="videoUrl && item.mediaType?.startsWith('audio/')"
          :src="videoUrl"
          class="content-detail-audio mb-4"
          controls
        ></audio>
        <a
          v-if="videoUrl"
          :href="videoUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="btn btn-outline-danger mb-4"
        >Ouvrir la source du média ↗</a>

        <section v-if="item.description" class="content-detail-section mb-4">
          <h2 class="h5 fw-bold">Présentation</h2>
          <p class="text-secondary mb-0"><TextWithLinks :text="item.description" /></p>
        </section>
        <section v-if="item.content" class="content-detail-section mb-4">
          <h2 class="h5 fw-bold">Histoire</h2>
          <p class="text-secondary mb-0"><TextWithLinks :text="item.content" /></p>
        </section>
        <section v-if="item.origins" class="content-detail-section mb-4">
          <h2 class="h5 fw-bold">Origines</h2>
          <p class="text-secondary mb-0"><TextWithLinks :text="item.origins" /></p>
        </section>
        <section v-if="item.culturalMeaning" class="content-detail-section mb-4">
          <h2 class="h5 fw-bold">Signification culturelle</h2>
          <p class="text-secondary mb-0"><TextWithLinks :text="item.culturalMeaning" /></p>
        </section>
        <section v-if="item.access" class="content-detail-section mb-0">
          <h2 class="h5 fw-bold">Conditions d’accès</h2>
          <p class="text-secondary mb-0"><TextWithLinks :text="item.access" /></p>
        </section>
      </article>
    </div>
  </main>
</template>
