<script setup>
import { ref } from 'vue'

const props = defineProps({ isAdmin: { type: Boolean, default: false }, events: { type: Array, default: () => [] }, proposedEvents: { type: Array, default: () => [] } })
const emit = defineEmits(['navigate', 'event-created', 'event-updated', 'event-deleted', 'proposal-validated', 'proposal-rejected'])
const editingEvent = ref(null)
const form = ref({ title: '', start: '', end: '', category: 'festival', location: '', description: '', imageUrl: '' })

function resetForm() {
  form.value = { title: '', start: '', end: '', category: 'festival', location: '', description: '', imageUrl: '' }
  editingEvent.value = null
}
function editEvent(event) {
  editingEvent.value = event
  form.value = { title: event.title, start: event.start, end: event.end, category: event.category, location: event.location, description: event.description, imageUrl: event.imageUrl || '' }
}
function saveEvent() {
  if (!form.value.title.trim() || !form.value.start || !form.value.end || !form.value.location.trim() || !form.value.description.trim()) return
  const event = { ...form.value, title: form.value.title.trim(), location: form.value.location.trim(), description: form.value.description.trim() }
  if (editingEvent.value) emit('event-updated', { ...editingEvent.value, ...event })
  else emit('event-created', { ...event, id: `event-${Date.now()}` })
  resetForm()
}
function removeEvent(event) {
  if (window.confirm(`Supprimer l'événement « ${event.title} » ?`)) emit('event-deleted', event)
}
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <div v-if="!props.isAdmin" class="alert alert-warning border-0 shadow-sm">Accès réservé aux administrateurs du DAC Mayotte.</div>
    <template v-else>
      <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4">
        <div><span class="badge rounded-pill eyebrow mb-3">ESPACE ADMINISTRATEUR</span><h1 class="fw-bold mb-2">Agenda culturel</h1><p class="text-secondary mb-0">Ajoutez, modifiez ou supprimez les événements du site.</p></div>
        <button class="btn btn-outline-dark" @click="emit('navigate', 'admin')">Retour au tableau de bord</button>
      </div>
      <section class="card border-0 shadow-sm mb-4">
        <div class="card-body p-4">
          <h2 class="h4 fw-bold">{{ editingEvent ? 'Modifier un événement' : 'Ajouter un événement' }}</h2>
          <form class="row g-3" @submit.prevent="saveEvent">
            <div class="col-md-6"><label class="form-label" for="event-title">Titre</label><input id="event-title" v-model="form.title" class="form-control" required></div>
            <div class="col-md-3"><label class="form-label" for="event-start">Début</label><input id="event-start" v-model="form.start" class="form-control" type="date" required></div>
            <div class="col-md-3"><label class="form-label" for="event-end">Fin</label><input id="event-end" v-model="form.end" class="form-control" type="date" required></div>
            <div class="col-md-4"><label class="form-label" for="event-category">Catégorie</label><select id="event-category" v-model="form.category" class="form-select"><option value="festival">Festival</option><option value="concert">Concert</option><option value="ceremonie">Cérémonie</option><option value="tradition">Tradition</option></select></div>
            <div class="col-md-8"><label class="form-label" for="event-location">Lieu</label><input id="event-location" v-model="form.location" class="form-control" required></div>
            <div class="col-12"><label class="form-label" for="event-description">Description</label><textarea id="event-description" v-model="form.description" class="form-control" rows="3" required></textarea></div>
            <div class="col-12"><label class="form-label" for="event-image-url">URL de l’image (facultative)</label><input id="event-image-url" v-model="form.imageUrl" type="url" class="form-control"></div>
            <div class="col-12 d-flex gap-2"><button class="btn btn-danger" type="submit">{{ editingEvent ? 'Enregistrer' : 'Ajouter' }}</button><button v-if="editingEvent" class="btn btn-light" type="button" @click="resetForm">Annuler</button></div>
          </form>
        </div>
      </section>
      <section class="card border-0 shadow-sm mb-4">
        <div class="card-body p-4">
          <h2 class="h4 fw-bold mb-3">Propositions des particuliers</h2>
          <article v-for="proposal in props.proposedEvents" :key="proposal.id" class="border-bottom py-3">
            <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">
              <div>
                <span class="badge" :class="proposal.status === 'À valider' ? 'text-bg-warning' : proposal.status === 'Validé' ? 'text-bg-success' : 'text-bg-secondary'">{{ proposal.status }}</span>
                <h3 class="h6 fw-bold mt-2 mb-1">{{ proposal.title }}</h3>
                <p class="small text-secondary mb-2">{{ proposal.start }} · {{ proposal.location }} · Proposé par {{ proposal.author }}</p>
                <img v-if="proposal.imageUrl" :src="proposal.imageUrl" :alt="proposal.imageName || proposal.title" class="img-fluid rounded mb-2" style="max-height: 220px">
                <p class="mb-0">{{ proposal.description }}</p>
              </div>
              <div v-if="proposal.status === 'À valider'" class="d-flex gap-2">
                <button class="btn btn-sm btn-outline-danger" @click="emit('proposal-rejected', proposal)">Refuser</button>
                <button class="btn btn-sm btn-success" @click="emit('proposal-validated', proposal)">Valider et publier</button>
              </div>
            </div>
          </article>
          <p v-if="!props.proposedEvents.length" class="text-secondary mb-0">Aucune proposition pour le moment.</p>
        </div>
      </section>
      <section class="card border-0 shadow-sm"><div class="card-body p-4"><h2 class="h4 fw-bold mb-3">Événements publiés</h2><div v-for="event in props.events" :key="event.id" class="border-bottom py-3 d-flex flex-wrap justify-content-between align-items-center gap-3"><img v-if="event.image" :src="event.image" :alt="event.title" class="rounded object-fit-cover" style="width: 88px; height: 72px"><div class="flex-grow-1"><h3 class="h6 fw-bold mb-1">{{ event.title }}</h3><p class="small text-secondary mb-0">{{ event.start }} · {{ event.location }}</p></div><div class="d-flex gap-2"><button class="btn btn-sm btn-outline-secondary" @click="editEvent(event)">Modifier</button><button class="btn btn-sm btn-outline-danger" @click="removeEvent(event)">Supprimer</button></div></div><p v-if="!props.events.length" class="text-secondary mb-0">Aucun événement.</p></div></section>
    </template>
  </main>
</template>
