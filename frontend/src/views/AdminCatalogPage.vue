<script setup>
import { computed, onMounted, ref } from 'vue'
import { apiRequest } from '../services/api.js'

const props = defineProps({ isAdmin: { type: Boolean, default: false }, token: { type: String, default: '' } })
const emit = defineEmits(['navigate', 'catalog-updated'])
const resources = [
  { key: 'articles', label: 'Contenus culturels', fields: [
    { key: 'title', label: 'Titre', required: true },
    { key: 'category', label: 'Catégorie', type: 'select', options: ['Histoires', 'Savoir-faire', 'Traditions'], default: 'Histoires', required: true },
    { key: 'village', label: 'Village' },
    { key: 'type', label: 'Format', required: true },
    { key: 'imageUrl', label: 'URL de la photo de couverture', type: 'url' },
    { key: 'mediaType', label: 'Type de média', type: 'select', options: [
      { value: 'video/mp4', label: 'Vidéo' },
      { value: 'audio/mpeg', label: 'Audio' },
    ], default: 'video/mp4' },
    { key: 'videoUrl', label: 'URL de l’extrait (YouTube, SoundCloud, Vimeo ou fichier)', type: 'url' },
    { key: 'description', label: 'Résumé affiché', type: 'textarea', rows: 4, required: true },
    { key: 'excerpt', label: 'Extrait', type: 'textarea', rows: 4 },
    { key: 'content', label: 'Histoire complète', type: 'textarea', rows: 8, required: true },
    { key: 'origins', label: 'Origines détaillées', type: 'textarea', rows: 6 },
    { key: 'culturalMeaning', label: 'Signification culturelle détaillée', type: 'textarea', rows: 6 },
    { key: 'discoveryPlace', label: 'Lieu où le découvrir (nom, adresse ou village)', type: 'textarea' },
  ] },
  { key: 'places', label: 'Lieux', fields: [
    { key: 'name', label: 'Nom du lieu', required: true },
    { key: 'village', label: 'Commune', required: true },
    { key: 'address', label: 'Adresse' },
    { key: 'googleMapsUrl', label: 'Lien direct Google Maps (facultatif)', type: 'url' },
    { key: 'access', label: 'Conditions d’accès', required: true },
    { key: 'description', label: 'Description', type: 'textarea' },
    { key: 'latitude', label: 'Latitude', type: 'number' },
    { key: 'longitude', label: 'Longitude', type: 'number' },
  ] },
  { key: 'quiz', label: 'Questions du quiz', fields: [
    { key: 'question', label: 'Question', required: true },
    { key: 'options', label: 'Réponses (une par ligne)', type: 'textarea', required: true },
    { key: 'answer', label: 'Numéro de la bonne réponse (à partir de 0)', type: 'number', required: true },
  ] },
]
const activeKey = ref('articles')
const collections = ref({ articles: [], places: [], quiz: [] })
const form = ref({})
const editingId = ref('')
const error = ref('')
const loading = ref(false)
const saving = ref(false)
const activeResource = computed(() => resources.find((resource) => resource.key === activeKey.value))
const activeItems = computed(() => collections.value[activeKey.value] || [])

function emptyForm() {
  return Object.fromEntries(activeResource.value.fields.map((field) => [
    field.key,
    field.type === 'number' ? 0 : field.default || '',
  ]))
}

function resetForm() {
  form.value = emptyForm()
  editingId.value = ''
}

async function loadCollections() {
  loading.value = true
  error.value = ''
  try {
    const entries = await Promise.all(resources.map(async (resource) => [
      resource.key,
      await apiRequest(`/catalog/${resource.key}`),
    ]))
    collections.value = Object.fromEntries(entries)
  } catch (requestError) {
    error.value = requestError.message
  } finally {
    loading.value = false
  }
}

function edit(item) {
  editingId.value = item.id
  form.value = { ...item }
  if (activeKey.value === 'quiz') form.value.options = item.options.join('\n')
  error.value = ''
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

async function save() {
  saving.value = true
  error.value = ''
  const body = { ...form.value }
  if (activeKey.value === 'quiz') body.options = body.options.split('\n').map((option) => option.trim()).filter(Boolean)
  try {
    await apiRequest(`/catalog/${activeKey.value}${editingId.value ? `/${encodeURIComponent(editingId.value)}` : ''}`, {
      method: editingId.value ? 'PUT' : 'POST',
      body,
      token: props.token,
    })
    await loadCollections()
    emit('catalog-updated')
    resetForm()
  } catch (requestError) {
    error.value = requestError.message
  } finally {
    saving.value = false
  }
}

async function remove(item) {
  const label = item.title || item.name || item.question
  if (!window.confirm(`Supprimer « ${label} » ?`)) return
  error.value = ''
  try {
    await apiRequest(`/catalog/${activeKey.value}/${encodeURIComponent(item.id)}`, { method: 'DELETE', token: props.token })
    await loadCollections()
    emit('catalog-updated')
    if (editingId.value === item.id) resetForm()
  } catch (requestError) {
    error.value = requestError.message
  }
}

function selectResource(key) {
  activeKey.value = key
  resetForm()
  error.value = ''
}

onMounted(() => {
  resetForm()
  loadCollections()
})
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <div v-if="!props.isAdmin" class="alert alert-warning border-0 shadow-sm">Accès réservé aux administrateurs du DAC Mayotte.</div>
    <template v-else>
      <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4">
        <div><span class="badge rounded-pill eyebrow mb-3">ESPACE ADMINISTRATEUR</span><h1 class="fw-bold mb-2">Gestion des contenus</h1><p class="text-secondary mb-0">Les modifications sont enregistrées dans MariaDB et publiées sur le site.</p></div>
        <button class="btn btn-outline-dark" @click="emit('navigate', 'admin')">Retour au tableau de bord</button>
      </div>

      <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>
      <div class="d-flex flex-wrap gap-2 mb-4" role="tablist" aria-label="Types de contenu">
        <button v-for="resource in resources" :key="resource.key" class="btn" :class="activeKey === resource.key ? 'btn-danger' : 'btn-outline-danger'" role="tab" :aria-selected="activeKey === resource.key" @click="selectResource(resource.key)">{{ resource.label }}</button>
      </div>

      <section class="card border-0 shadow-sm mb-4">
        <div class="card-body p-4">
          <h2 class="h4 fw-bold">{{ editingId ? 'Modifier' : 'Ajouter' }} : {{ activeResource.label }}</h2>
          <p v-if="activeKey === 'articles'" class="small text-secondary">Pour les contenus de Savoir-faire et Traditions, vous pouvez ajouter un extrait audio ou vidéo court. Les liens YouTube, Vimeo et SoundCloud sont intégrés à la fiche; les fichiers audio/vidéo directs sont lus sur le site.</p>
          <form class="row g-3" @submit.prevent="save">
            <div v-for="field in activeResource.fields" :key="field.key" class="col-md-6">
              <label class="form-label" :for="`catalog-${field.key}`">{{ field.label }}</label>
              <textarea v-if="field.type === 'textarea'" :id="`catalog-${field.key}`" v-model="form[field.key]" class="form-control" :rows="field.rows || 3" :required="field.required"></textarea>
              <select v-else-if="field.type === 'select'" :id="`catalog-${field.key}`" v-model="form[field.key]" class="form-select" :required="field.required">
                <option v-for="option in field.options" :key="option.value || option" :value="option.value || option">{{ option.label || option }}</option>
              </select>
              <input v-else :id="`catalog-${field.key}`" v-model="form[field.key]" class="form-control" :type="field.type || 'text'" :required="field.required" :min="field.type === 'number' ? 0 : undefined">
            </div>
            <div class="col-12 d-flex gap-2">
              <button class="btn btn-danger" type="submit" :disabled="saving">{{ saving ? 'Enregistrement…' : editingId ? 'Enregistrer' : 'Ajouter' }}</button>
              <button v-if="editingId" class="btn btn-light" type="button" @click="resetForm">Annuler</button>
            </div>
          </form>
        </div>
      </section>

      <section class="card border-0 shadow-sm">
        <div class="card-body p-4">
          <h2 class="h4 fw-bold mb-3">{{ activeResource.label }} enregistrés</h2>
          <p v-if="loading" class="text-secondary">Chargement…</p>
          <p v-else-if="!activeItems.length" class="text-secondary mb-0">Aucun élément enregistré.</p>
          <article v-for="item in activeItems" :key="item.id" class="border-bottom py-3 d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div class="flex-grow-1"><h3 class="h6 fw-bold mb-1">{{ item.title || item.name || item.question }}</h3><p class="small text-secondary mb-0">{{ item.theme || item.kind || item.village || (item.options ? `${item.options.length} réponses` : '') }}</p></div>
            <div class="d-flex gap-2"><button class="btn btn-sm btn-outline-secondary" @click="edit(item)">Modifier</button><button class="btn btn-sm btn-outline-danger" @click="remove(item)">Supprimer</button></div>
          </article>
        </div>
      </section>
    </template>
  </main>
</template>
