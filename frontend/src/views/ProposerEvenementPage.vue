<script setup>
import { ref } from 'vue'
import { apiRequest } from '../services/api.js'

const props = defineProps({ isAuthenticated: { type: Boolean, default: false }, currentUser: { type: Object, default: null }, authToken: { type: String, default: '' } })
const emit = defineEmits(['navigate', 'event-proposed'])
const sent = ref(false)
const loginRequired = ref(false)
const saving = ref(false)
const submitError = ref('')
const form = ref({ title: '', date: '', location: '', description: '', imageUrl: '' })

async function submit() {
  if (!props.isAuthenticated) {
    loginRequired.value = true
    return
  }
  saving.value = true
  submitError.value = ''
  try {
    await apiRequest('/events/proposals', {
      method: 'POST',
      token: props.authToken,
      body: {
        ...form.value,
        title: form.value.title.trim(),
        location: form.value.location.trim(),
        description: form.value.description.trim(),
        category: 'festival',
        author: props.currentUser?.name || props.currentUser?.email || 'Membre',
      },
    })
    sent.value = true
    emit('event-proposed')
  } catch (error) {
    submitError.value = error.message
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <span class="badge rounded-pill eyebrow mb-3">ESPACE PARTICULIER</span>
    <h1 class="fw-bold mb-2">Faites connaître votre événement</h1>
    <p class="text-secondary mb-4">Proposez une fête, une exposition, un atelier ou une cérémonie à l’agenda culturel de Mayotte.</p>

    <div class="row g-4">
      <section class="col-lg-7">
        <div v-if="loginRequired" class="alert alert-warning border-0 shadow-sm">
          <h2 class="h5">Connexion requise</h2>
          <p class="mb-3">Connectez-vous pour transmettre votre événement à l’équipe de validation.</p>
          <button class="btn btn-danger" @click="emit('navigate', 'profil')">Se connecter</button>
        </div>
        <form v-if="!sent" class="card border-0 shadow-sm p-4" @submit.prevent="submit">
          <div class="row g-3">
            <div class="col-12">
              <label class="form-label" for="proposal-title">Titre de l’événement</label>
              <input id="proposal-title" v-model="form.title" class="form-control" required maxlength="120" placeholder="Ex. Atelier de tressage traditionnel">
            </div>
            <div class="col-md-6">
              <label class="form-label" for="proposal-date">Date</label>
              <input id="proposal-date" v-model="form.date" class="form-control" type="date" required>
            </div>
            <div class="col-md-6">
              <label class="form-label" for="proposal-location">Lieu</label>
              <input id="proposal-location" v-model="form.location" class="form-control" required maxlength="160" placeholder="Commune, salle ou adresse">
            </div>
            <div class="col-12">
              <label class="form-label" for="proposal-description">Description</label>
              <textarea id="proposal-description" v-model="form.description" class="form-control" rows="5" required maxlength="1500" placeholder="Présentez l’événement et les informations utiles aux visiteurs."></textarea>
            </div>
            <div class="col-12"><label class="form-label" for="event-image-url">URL de l’image (facultative)</label><input id="event-image-url" v-model="form.imageUrl" type="url" class="form-control" placeholder="https://…"></div>
          </div>
          <p v-if="submitError" class="text-danger small mt-3 mb-0">{{ submitError }}</p>
          <button class="btn btn-danger fw-bold mt-3" type="submit" :disabled="saving">{{ saving ? 'Envoi…' : 'Envoyer pour validation' }} <span>↗</span></button>
        </form>
        <div v-else class="alert alert-success border-0 shadow-sm">
          <h2 class="h5 fw-bold">Votre événement a bien été transmis</h2>
          <p class="mb-0">L’équipe DAC Mayotte vérifiera votre proposition. Elle apparaîtra dans l’agenda public après validation.</p>
        </div>
      </section>

      <aside class="col-lg-5">
        <div class="card border-0 shadow-sm p-4">
          <h2 class="h5 fw-bold">Après l’envoi</h2>
          <ol class="small mb-0">
            <li class="mb-2">Votre proposition est transmise à l’administration.</li>
            <li class="mb-2">L’équipe vérifie les informations avant publication.</li>
            <li>Une fois validé, l’événement rejoint l’agenda consulté par les visiteurs.</li>
          </ol>
        </div>
      </aside>
    </div>
  </main>
</template>
