<script setup>
import { ref } from 'vue'

const props = defineProps({
  isAuthenticated: { type: Boolean, default: false },
  isAdmin: { type: Boolean, default: false },
  currentUser: { type: Object, default: null },
  authError: { type: String, default: '' },
  loginError: { type: String, default: '' },
})
const emit = defineEmits(['member-auth', 'admin-login', 'navigate', 'disconnect'])
const mode = ref('login')
const credentials = ref({ nom: '', prenom: '', email: '', password: '' })
const adminCredentials = ref({ email: '', password: '' })
const adminMode = ref(false)

function submitMember() {
  emit('member-auth', { mode: mode.value, credentials: { ...credentials.value } })
}

function submitAdmin() {
  emit('admin-login', { ...adminCredentials.value })
}
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
    <span class="badge rounded-pill eyebrow mb-3">ESPACE COMMUNAUTAIRE</span>
    <h1 class="fw-bold mb-2">Votre profil culturel</h1>
    <p class="text-secondary mb-4">Connectez-vous pour partager vos histoires et suivre vos contributions.</p>

    <section v-if="props.isAuthenticated" class="profile-layout container-wide">
      <aside class="profile-card">
        <span class="profile-avatar">{{ props.currentUser?.name?.slice(0, 2).toUpperCase() || 'NM' }}</span>
        <h2>{{ props.currentUser?.name || 'Administrateur' }}</h2>
        <p>{{ props.currentUser?.email }}</p>
        <p class="text-success fw-bold">Connecté à la communauté</p>
        <button class="btn btn-outline-dark" @click="emit('disconnect')">Se déconnecter</button>
      </aside>
      <div class="contribution-form">
        <span class="eyebrow">COMMUNAUTÉ</span>
        <h2>Bienvenue dans votre espace membre</h2>
        <p>Partagez un fragment de mémoire avec la communauté mahoraise.</p>
        <button class="btn btn-danger fw-bold" @click="emit('navigate', 'contribuer')">Contribuer maintenant <span>↗</span></button>
        <button class="btn btn-outline-danger fw-bold ms-2" @click="emit('navigate', 'proposer-evenement')">Proposer un événement <span>↗</span></button>
      </div>
    </section>

    <section v-else class="login-section card border-0 shadow-sm">
      <div class="login-form p-4 p-lg-5">
        <template v-if="!adminMode">
          <div class="d-flex gap-2 mb-4">
            <button class="btn" :class="mode === 'login' ? 'btn-danger' : 'btn-outline-danger'" @click="mode = 'login'">Connexion membre</button>
            <button class="btn" :class="mode === 'register' ? 'btn-danger' : 'btn-outline-danger'" @click="mode = 'register'">Créer un compte</button>
          </div>
          <form @submit.prevent="submitMember">
            <h2 class="h3 fw-bold">{{ mode === 'login' ? 'Retrouvez votre communauté' : 'Créer un compte membre' }}</h2>
            <template v-if="mode === 'register'">
              <label class="form-label mt-3" for="member-prenom">Prénom</label>
              <input id="member-prenom" v-model="credentials.prenom" class="form-control" autocomplete="given-name" required maxlength="100">
              <label class="form-label mt-3" for="member-nom">Nom</label>
              <input id="member-nom" v-model="credentials.nom" class="form-control" autocomplete="family-name" required maxlength="100">
            </template>
            <label class="form-label mt-3" for="member-email">Adresse e-mail</label>
            <input id="member-email" v-model="credentials.email" class="form-control" type="email" autocomplete="email" required maxlength="255">
            <label class="form-label mt-3" for="member-password">Mot de passe</label>
            <input id="member-password" v-model="credentials.password" class="form-control" type="password" :autocomplete="mode === 'login' ? 'current-password' : 'new-password'" :minlength="mode === 'register' ? 10 : undefined" required>
            <p v-if="mode === 'register'" class="form-text">Au moins 10 caractères.</p>
            <p v-if="props.authError" class="text-danger small mt-3 mb-0" role="alert">{{ props.authError }}</p>
            <button class="btn btn-danger fw-bold mt-4" type="submit">{{ mode === 'login' ? 'Se connecter' : 'Créer mon compte' }} <span>↗</span></button>
          </form>
        </template>
        <form v-else @submit.prevent="submitAdmin">
          <h2 class="h3 fw-bold">Connexion administrateur</h2>
          <label class="form-label mt-3" for="admin-email">Adresse e-mail</label>
          <input id="admin-email" v-model="adminCredentials.email" class="form-control" type="email" autocomplete="username" required>
          <label class="form-label mt-3" for="admin-password">Mot de passe</label>
          <input id="admin-password" v-model="adminCredentials.password" class="form-control" type="password" autocomplete="current-password" required>
          <p v-if="props.loginError" class="text-danger small mt-3 mb-0" role="alert">{{ props.loginError }}</p>
          <button class="btn btn-danger fw-bold mt-4" type="submit">Se connecter</button>
        </form>
        <button class="btn btn-link mt-3 px-0" @click="adminMode = !adminMode">{{ adminMode ? 'Connexion membre' : 'Espace administrateur' }}</button>
      </div>
    </section>
  </main>
</template>
