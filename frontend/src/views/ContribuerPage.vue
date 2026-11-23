<script setup>
import { computed, ref } from 'vue'
import { apiRequest } from '../services/api.js'

const props = defineProps({ isAuthenticated: { type: Boolean, default: false }, authToken: { type: String, default: '' } })
const emit = defineEmits(['contribution-submitted', 'navigate'])
const sent = ref(false)
const loginRequired = ref(false)
const saving = ref(false)
const submitError = ref('')
const form = ref({ type: 'Récit', title: '', village: '', content: '', imageUrl: '', mediaUrl: '', mediaType: '', youtubeUrl: '' })
const youtubeLink = computed(() => {
  try {
    const url = new URL(form.value.youtubeUrl)
    return ['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be', 'www.youtu.be'].includes(url.hostname) && ['http:', 'https:'].includes(url.protocol) ? url.href : ''
  } catch {
    return ''
  }
})

async function submit() {
  if (!props.isAuthenticated) {
    loginRequired.value = true
    return
  }
  saving.value = true
  submitError.value = ''
  try {
    await apiRequest('/contributions', {
      method: 'POST',
      token: props.authToken,
      body: {
        title: form.value.title,
        type: form.value.type,
        village: form.value.village,
        content: form.value.content,
        imageUrl: form.value.imageUrl,
        mediaUrl: form.value.mediaUrl,
        mediaType: form.value.mediaType,
        youtubeUrl: youtubeLink.value,
        charterAccepted: true,
      },
    })
    sent.value = true
    emit('contribution-submitted')
  } catch (error) {
    submitError.value = error.message
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <span class="badge rounded-pill eyebrow mb-3">ESPACE COMMUNAUTAIRE</span>
    <h1 class="fw-bold mb-2">Partagez votre histoire</h1>
    <p class="text-secondary mb-4">Contribuez à la mémoire de Mayotte et retrouvez vos contenus favoris.</p>
    <div class="row g-4">
      <section class="col-lg-7">
        <div v-if="loginRequired" class="alert alert-warning border-0 shadow-sm">
          <h2 class="h5">Connexion requise pour envoyer</h2>
          <p class="mb-3">Votre contenu est prêt, mais vous devez vous connecter avant de l’envoyer à la modération.</p>
          <button class="btn btn-danger" @click="emit('navigate', 'profil')">Se connecter</button>
        </div>
        <form v-if="!sent" class="card border-0 shadow-sm p-4" @submit.prevent="submit">
          <div class="row g-3">
            <div class="col-12"><label class="form-label" for="content-type">Type de contenu</label><select id="content-type" v-model="form.type" class="form-select"><option>Récit</option><option>Histoire</option><option>Savoir-faire</option><option>Photo</option><option>Vidéo</option><option>Témoignage audio</option></select></div>
            <div class="col-12"><label class="form-label" for="content-title">Titre de contenu</label><input id="content-title" v-model="form.title" required class="form-control" placeholder="Donnez un titre à votre contribution"></div>
            <div class="col-12"><label class="form-label" for="village">Village concerné</label><input id="village" v-model="form.village" class="form-control" placeholder="Ex. Sada"></div>
            <div class="col-12">
              <label class="form-label" for="illustration-url">URL de l’image (facultative)</label>
              <input id="illustration-url" v-model="form.imageUrl" type="url" class="form-control" placeholder="https://…">
            </div>
            <div class="col-md-8">
              <label class="form-label" for="media-url">URL du média audio ou vidéo (facultative)</label>
              <input id="media-url" v-model="form.mediaUrl" type="url" class="form-control" placeholder="https://…">
            </div>
            <div class="col-md-4">
              <label class="form-label" for="media-type">Type de média</label>
              <select id="media-type" v-model="form.mediaType" class="form-select"><option value="">Aucun</option><option value="audio/mpeg">Audio</option><option value="video/mp4">Vidéo</option></select>
            </div>
            <div class="col-12">
              <label class="form-label" for="youtube-url">Lien YouTube (facultatif)</label>
              <input id="youtube-url" v-model="form.youtubeUrl" type="url" class="form-control" placeholder="https://www.youtube.com/watch?v=…">
              <a v-if="youtubeLink" :href="youtubeLink" target="_blank" rel="noopener noreferrer" class="btn btn-outline-danger btn-sm mt-2">Ouvrir la vidéo sur YouTube ↗</a>
              <p v-else-if="form.youtubeUrl" class="small text-danger mt-2 mb-0">Saisissez un lien YouTube valide.</p>
            </div>
            <div class="col-12"><label class="form-label" for="story">Votre récit</label><textarea id="story" v-model="form.content" required rows="5" class="form-control" placeholder="Racontez, décrivez ou transmettez ce savoir…"></textarea></div>
          </div>
          <div class="form-check mt-3"><input id="agreement" required class="form-check-input" type="checkbox"><label for="agreement" class="form-check-label small">Je confirme pouvoir partager ce contenu et accepte la charte de validation.</label></div>
          <p v-if="submitError" class="text-danger small mt-3 mb-0">{{ submitError }}</p>
          <button class="btn btn-danger fw-bold mt-2 w-auto" type="submit" :disabled="saving">{{ saving ? 'Envoi…' : 'Envoyer à la modération' }} <span>↗</span></button>
        </form>
        <div v-else class="alert alert-success border-0 shadow-sm"><h2 class="h5 fw-bold">Merci pour votre contribution !</h2><p class="mb-0">Elle a été transmise à l’équipe de modération DAC Mayotte. Vous serez informé de son traitement.</p></div>
      </section>
      <aside class="col-lg-5"><div class="card border-0 shadow-sm p-4"><h2 class="h5 fw-bold">Comment cela fonctionne ?</h2><ol class="small mb-0"><li class="mb-2">Vous déposez un récit ou un média.</li><li class="mb-2">La DAC vérifie le contenu et peut demander une précision.</li><li>Après validation, il rejoint la bibliothèque culturelle.</li></ol></div></aside>
    </div>
  </main>
</template>