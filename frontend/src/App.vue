<script setup>
import { computed, onMounted, ref } from 'vue'
import Navbar from './components/Navbar.vue'
import Hero from './components/Hero.vue'
import Footer from './components/Footer.vue'
import AccueilPage from './views/AccueilPage.vue'
import ExplorerPage from './views/ExplorerPage.vue'
import LieuxMemoirePage from './views/LieuxMemoirePage.vue'
import EvenementsPage from './views/EvenementsPage.vue'
import QuizPage from './views/QuizPage.vue'
import ProfilPage from './views/ProfilPage.vue'
import ContribuerPage from './views/ContribuerPage.vue'
import DiasporaPage from './views/DiasporaPage.vue'
import AProposPage from './views/AProposPage.vue'
import ModerationPage from './views/ModerationPage.vue'
import AdminPage from './views/AdminPage.vue'
import CommunityProfilesPage from './views/CommunityProfilesPage.vue'
import AdminEventsPage from './views/AdminEventsPage.vue'
import AdminCatalogPage from './views/AdminCatalogPage.vue'
import ProposerEvenementPage from './views/ProposerEvenementPage.vue'
import ContactPage from './views/ContactPage.vue'
import { apiRequest } from './services/api.js'
import { fallbackArticleImages, fallbackEventImages, fallbackPlaceImage } from './data/siteData.js'

function pageFromPath(path) {
  if (path === '/admin') return 'admin'
  if (path === '/admin/moderation') return 'moderation'
  if (path === '/admin/profils') return 'community-profiles'
  if (path === '/admin/explorer') return 'explorer'
  if (path === '/admin/evenements') return 'admin-events'
  if (path === '/admin/contenus') return 'admin-catalog'
  return 'accueil'
}

const basePath = import.meta.env.BASE_URL.replace(/\/$/, '')

function routeFromLocation(path) {
  if (basePath && (path === basePath || path.startsWith(`${basePath}/`))) {
    return path.slice(basePath.length) || '/'
  }
  return path || '/'
}

function locationFromRoute(path) {
  return `${basePath}${path === '/' ? '/' : path}` || '/'
}

const routePath = ref(routeFromLocation(window.location.pathname))
const activePage = ref(pageFromPath(routePath.value))
const adminToken = ref(sessionStorage.getItem('culvite-admin-token') || '')
const memberToken = ref(sessionStorage.getItem('culvite-member-token') || '')
const isAdmin = ref(Boolean(adminToken.value))
const isAuthenticated = ref(isAdmin.value || Boolean(memberToken.value))
const adminLoginError = ref('')
const memberAuthError = ref('')
const apiError = ref('')
const currentUser = ref(isAdmin.value ? { email: 'Administrateur', name: 'Administrateur' } : null)
const contributors = ref([])
const publishedArticles = ref([])
const places = ref([])
const quizQuestions = ref([])
const managedEvents = ref([])
const selectedItem = ref(null)
const submittedContributions = ref([])
const isLoading = ref(true)
const pages = { accueil: AccueilPage, explorer: ExplorerPage, 'lieux-memoire': LieuxMemoirePage, evenements: EvenementsPage, contribuer: ContribuerPage, 'proposer-evenement': ProposerEvenementPage, diaspora: DiasporaPage, apropos: AProposPage, moderation: ModerationPage, admin: AdminPage, 'community-profiles': CommunityProfilesPage, 'admin-events': AdminEventsPage, 'admin-catalog': AdminCatalogPage, contact: ContactPage, quiz: QuizPage, profil: ProfilPage }
const currentPage = computed(() => pages[activePage.value] || AccueilPage)
const authToken = computed(() => isAdmin.value ? adminToken.value : memberToken.value)
const allEvents = computed(() => managedEvents.value.filter((event) => event.status === 'Validé'))
const proposedEvents = computed(() => managedEvents.value.filter((event) => event.status !== 'Validé'))
const isAdminRoute = computed(() => routePath.value.startsWith('/admin'))

function withImage(item, fallbacks, defaultImage = '') {
  return { ...item, image: item.imageUrl || fallbacks[item.id] || defaultImage }
}

function contributionAsArticle(contribution) {
  const createdAt = contribution.createdAt ? new Date(contribution.createdAt).getTime() : 0
  return {
    id: `contribution-${contribution.id}`,
    sourceContributionId: contribution.id,
    category: 'Histoires',
    theme: 'Histoires',
    title: contribution.title,
    village: contribution.village || 'Mayotte',
    generation: `Récit de ${contribution.author || 'la communauté'}`,
    type: contribution.type,
    image: contribution.imageUrl || fallbackArticleImages['article-1'],
    imageUrl: contribution.imageUrl || '',
    imageName: contribution.imageName || '',
    description: contribution.content,
    excerpt: contribution.content,
    content: contribution.content,
    mediaUrl: contribution.mediaUrl || '',
    mediaName: contribution.mediaName || '',
    mediaType: contribution.mediaType || '',
    youtubeUrl: contribution.youtubeUrl || '',
    createdAt,
  }
}

async function loadSiteData() {
  isLoading.value = true
  apiError.value = ''
  try {
    const [events, contributions, community, articles, placeList, questions] = await Promise.all([
      apiRequest('/events'),
      apiRequest('/contributions/published'),
      apiRequest('/contributors'),
      apiRequest('/catalog/articles'),
      apiRequest('/catalog/places'),
      apiRequest('/catalog/quiz'),
    ])
    let eventList = events
    if (isAdmin.value) {
      const [allEventsFromApi, allContributions] = await Promise.all([
        apiRequest('/admin/events', { token: adminToken.value }),
        apiRequest('/contributions', { token: adminToken.value }),
      ])
      eventList = allEventsFromApi
      submittedContributions.value = allContributions
    }
    managedEvents.value = eventList.map((event) => withImage(event, fallbackEventImages, fallbackEventImages['event-1']))
    publishedArticles.value = [
      ...articles.map((article) => withImage(article, fallbackArticleImages, fallbackArticleImages['article-1'])),
      ...contributions.map(contributionAsArticle),
    ]
    contributors.value = community
    places.value = placeList.map((place) => ({ ...place, image: place.imageUrl || fallbackPlaceImage }))
    quizQuestions.value = questions
  } catch (error) {
    if (error.status === 401 && isAdmin.value) {
      adminToken.value = ''
      isAdmin.value = false
      isAuthenticated.value = false
      currentUser.value = null
      submittedContributions.value = []
      sessionStorage.removeItem('culvite-admin-token')
      apiError.value = 'Votre session administrateur a expiré. Veuillez vous reconnecter.'
      return
    }
    apiError.value = error.message
  } finally {
    isLoading.value = false
  }
}

function navigate(page) {
  const targetPath = page === 'admin' ? '/admin'
    : page === 'moderation' && routePath.value.startsWith('/admin') ? '/admin/moderation'
      : page === 'community-profiles' ? '/admin/profils'
        : page === 'explorer' && routePath.value.startsWith('/admin') ? '/admin/explorer'
          : page === 'admin-events' ? '/admin/evenements'
            : page === 'admin-catalog' ? '/admin/contenus' : '/'
  if (routePath.value !== targetPath) {
    window.history.pushState({}, '', locationFromRoute(targetPath))
    routePath.value = targetPath
  }
  activePage.value = pages[page] ? page : 'accueil'
  selectedItem.value = null
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

async function connectMember({ mode, credentials }) {
  memberAuthError.value = ''
  try {
    const result = await apiRequest(mode === 'register' ? '/auth/register' : '/auth/login', {
      method: 'POST',
      body: credentials,
    })
    memberToken.value = result.token
    sessionStorage.setItem('culvite-member-token', result.token)
    currentUser.value = result.user
    isAuthenticated.value = true
    await loadSiteData()
  } catch (error) {
    memberAuthError.value = error.message
  }
}

async function connectAdmin(credentials) {
  adminLoginError.value = ''
  try {
    const result = await apiRequest('/admin/login', { method: 'POST', body: credentials })
    adminToken.value = result.token
    sessionStorage.setItem('culvite-admin-token', result.token)
    isAdmin.value = true
    isAuthenticated.value = true
    currentUser.value = { email: result.user.email, name: 'Administrateur' }
    await loadSiteData()
  } catch (error) {
    adminLoginError.value = error.message
  }
}

function disconnect() {
  currentUser.value = null
  isAuthenticated.value = false
  isAdmin.value = false
  adminToken.value = ''
  memberToken.value = ''
  submittedContributions.value = []
  sessionStorage.removeItem('culvite-admin-token')
  sessionStorage.removeItem('culvite-member-token')
  navigate('accueil')
  loadSiteData()
}

function openItem(item) { selectedItem.value = item }

async function updateContribution(contribution) {
  try {
    await apiRequest(`/contributions/${encodeURIComponent(contribution.id)}`, { method: 'PUT', body: contribution, token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function deleteContribution(contribution) {
  try {
    await apiRequest(`/contributions/${encodeURIComponent(contribution.id)}`, { method: 'DELETE', token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function validateContribution(contribution) {
  try {
    await apiRequest(`/contributions/${encodeURIComponent(contribution.id)}/status`, { method: 'PATCH', body: { status: contribution.status }, token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function addEvent(event) {
  try {
    await apiRequest('/events', { method: 'POST', body: event, token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function updateEvent(event) {
  try {
    await apiRequest(`/events/${encodeURIComponent(event.id)}`, { method: 'PUT', body: event, token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function deleteEvent(event) {
  try {
    await apiRequest(`/events/${encodeURIComponent(event.id)}`, { method: 'DELETE', token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

async function updateProposalStatus(event, status) {
  try {
    await apiRequest(`/admin/events/${encodeURIComponent(event.id)}/status`, { method: 'PATCH', body: { status }, token: adminToken.value })
    await loadSiteData()
  } catch (error) { apiError.value = error.message }
}

function validateProposedEvent(event) { return updateProposalStatus(event, 'Validé') }
function rejectProposedEvent(event) { return updateProposalStatus(event, 'Refusé') }

onMounted(() => {
  window.addEventListener('popstate', () => {
    routePath.value = routeFromLocation(window.location.pathname)
    activePage.value = pageFromPath(routePath.value)
  })
  if (memberToken.value && !isAdmin.value) {
    apiRequest('/auth/me', { token: memberToken.value })
      .then((user) => { currentUser.value = user })
      .catch(() => {
        memberToken.value = ''
        isAuthenticated.value = false
        sessionStorage.removeItem('culvite-member-token')
      })
      .finally(loadSiteData)
  } else {
    loadSiteData()
  }
})
</script>

<template>
  <template v-if="isAdminRoute">
    <Navbar admin-mode :active-page="activePage" :is-authenticated="isAuthenticated" :is-admin="isAdmin" @navigate="navigate" @disconnect="disconnect" />
    <div v-if="apiError" class="container alert alert-danger mt-3" role="alert">{{ apiError }}</div>
    <div v-if="isLoading" class="container py-4 text-secondary" role="status">Chargement des données…</div>
    <component :is="currentPage" :items="submittedContributions" :articles="publishedArticles" :events="managedEvents" :proposed-events="proposedEvents" :contributors="contributors" :places="places" :questions="quizQuestions" :token="adminToken" :auth-token="authToken" :is-authenticated="isAuthenticated" :is-admin="isAdmin" :login-error="adminLoginError" :auth-error="memberAuthError" :current-user="currentUser" @navigate="navigate" @member-auth="connectMember" @admin-login="connectAdmin" @event-created="addEvent" @event-updated="updateEvent" @event-deleted="deleteEvent" @proposal-validated="validateProposedEvent" @proposal-rejected="rejectProposedEvent" @open-article="openItem" @open-event="openItem" @open-place="openItem" @contribution-validated="validateContribution" @contribution-updated="updateContribution" @contribution-deleted="deleteContribution" @catalog-updated="loadSiteData" />
    <Footer admin-mode />
  </template>
  <template v-else>
    <Navbar :active-page="activePage" :is-authenticated="isAuthenticated" :is-admin="isAdmin" @navigate="navigate" @disconnect="disconnect" />
    <div v-if="apiError" class="container alert alert-danger mt-3" role="alert">{{ apiError }}</div>
    <div v-if="isLoading" class="container py-4 text-secondary" role="status">Chargement des données…</div>
    <Hero v-if="activePage === 'accueil'" @navigate="navigate" />
    <main class="container my-4"><component :is="currentPage" :items="submittedContributions" :articles="publishedArticles" :events="allEvents" :proposed-events="proposedEvents" :contributors="contributors" :places="places" :questions="quizQuestions" :is-authenticated="isAuthenticated" :is-admin="isAdmin" :auth-token="authToken" :auth-error="memberAuthError" :login-error="adminLoginError" :current-user="currentUser" @navigate="navigate" @member-auth="connectMember" @admin-login="connectAdmin" @event-proposed="loadSiteData" @contribution-submitted="loadSiteData" @open-article="openItem" @open-event="openItem" @open-place="openItem" /></main>
    <Footer @navigate="navigate" />
  </template>
  <div v-if="selectedItem" class="modal-backdrop-custom" @click.self="selectedItem = null">
    <div class="modal-card bg-white rounded-3 shadow p-4">
      <button class="btn-close float-end" @click="selectedItem = null"></button>
      <h2 class="h4 pe-4">{{ selectedItem.title || selectedItem.name }}</h2>
      <img v-if="selectedItem.image" :src="selectedItem.image" :alt="selectedItem.title || selectedItem.name" class="modal-image rounded-3 mb-3">
      <video v-if="selectedItem.mediaType?.startsWith('video/')" :src="selectedItem.mediaUrl" class="w-100 rounded mb-3" controls playsinline></video>
      <audio v-else-if="selectedItem.mediaType?.startsWith('audio/')" :src="selectedItem.mediaUrl" class="w-100 mb-3" controls></audio>
      <a v-if="selectedItem.youtubeUrl" :href="selectedItem.youtubeUrl" target="_blank" rel="noopener noreferrer" class="btn btn-outline-danger btn-sm mb-3">Regarder la vidéo sur YouTube ↗</a>
      <p class="text-secondary">{{ selectedItem.description || selectedItem.content }}</p>
      <p v-if="selectedItem.theme || selectedItem.type" class="small text-secondary mb-3">{{ selectedItem.theme }}<span v-if="selectedItem.theme && selectedItem.type"> · </span>{{ selectedItem.type }}</p>
      <p v-if="selectedItem.location" class="mb-3"><strong>Lieu :</strong> {{ selectedItem.location }}</p>
      <button class="btn btn-danger" @click="selectedItem = null">Fermer</button>
    </div>
  </div>
</template>
