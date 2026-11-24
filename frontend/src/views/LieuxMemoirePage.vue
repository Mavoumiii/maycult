<script setup>
defineProps({ places: { type: Array, default: () => [] } })

function mapUrl(place) {
  if (place.googleMapsUrl) return place.googleMapsUrl

  const query = place.latitude != null && place.longitude != null
    ? `${place.latitude},${place.longitude}`
    : [place.name, place.address, place.village, 'Mayotte'].filter(Boolean).join(', ')
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(query)}`
}
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <span class="badge rounded-pill eyebrow mb-3">Sur la carte</span>
    <section class="section container-wide px-0">
      <div class="section-heading">
        <div>
          <span class="section-kicker">Patrimoine vivant</span>
          <h1 class="h2 fw-bold mb-0">Lieux de mémoire</h1>
        </div>
      </div>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Lieu</th>
              <th>Village</th>
              <th>Adresse</th>
              <th>Conditions d’accès</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="place in places" :key="place.name">
              <td><a :href="mapUrl(place)" :aria-label="`Ouvrir ${place.name} sur Google Maps`" target="_blank" rel="noopener noreferrer"><strong>{{ place.name }}</strong> ↗</a></td>
              <td>{{ place.village }}</td>
              <td>{{ place.address || '—' }}</td>
              <td><span class="status">{{ place.access }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</template>