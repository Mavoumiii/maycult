<script setup>
import { computed } from 'vue'

const props = defineProps({
  text: { type: String, default: '' },
})

const segments = computed(() => {
  const result = []
  const pattern = /https?:\/\/[^\s<>"']+/g
  let cursor = 0

  for (const match of props.text.matchAll(pattern)) {
    const rawUrl = match[0]
    const url = rawUrl.replace(/[.,!?;:]+$/, '')
    const trailingText = rawUrl.slice(url.length)

    if (match.index > cursor) result.push({ text: props.text.slice(cursor, match.index) })

    try {
      const parsedUrl = new URL(url)
      if (parsedUrl.protocol === 'http:' || parsedUrl.protocol === 'https:') {
        result.push({ text: url, href: url })
      } else {
        result.push({ text: url })
      }
    } catch {
      result.push({ text: url })
    }

    if (trailingText) result.push({ text: trailingText })
    cursor = match.index + rawUrl.length
  }

  if (cursor < props.text.length) result.push({ text: props.text.slice(cursor) })
  return result
})
</script>

<template>
  <template v-for="(segment, index) in segments" :key="index">
    <a
      v-if="segment.href"
      :href="segment.href"
      target="_blank"
      rel="noopener noreferrer"
    >{{ segment.text }}</a>
    <span v-else>{{ segment.text }}</span>
  </template>
</template>
