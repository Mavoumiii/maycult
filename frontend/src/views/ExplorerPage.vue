<script setup>
import { ref, computed } from 'vue'
const props = defineProps({ articles: { type: Array, default: () => [] }, isAdmin: { type: Boolean, default: false } })
const emit = defineEmits(['open-item', 'navigate'])
const categories = ['Histoires', 'Savoir-faire', 'Traditions']
const activeCategory = ref('Toutes')
const search = ref('')
const filteredArticles = computed(() => props.articles.filter((article) => {
  const category = article.category || article.theme
  const matchesCategory = categories.includes(category)
    && (activeCategory.value === 'Toutes' || category === activeCategory.value)
  const matchesSearch = `${article.title} ${article.village} ${article.description}`.toLowerCase().includes(search.value.toLowerCase())
  return matchesCategory && matchesSearch
}))
</script>

<template>
  <main class="page-shell p-4 p-lg-5">
        <span class="badge rounded-pill eyebrow mb-3">Bibliothèque culturelle</span>
        <div class="d-flex flex-wrap justify-content-between align-items-start gap-3">
          <div>
            <h1 class="fw-bold mb-2">Explorer la culture</h1>
            <p class="text-secondary mb-4">Des histoires, des gestes et des visages classés pour vous accompagner dans votre découverte.</p>
          </div>
          <button v-if="props.isAdmin" class="btn btn-outline-dark" @click="emit('navigate', 'admin')">Retour au tableau de bord</button>
        </div>
    <section class="filter-panel rounded-4 p-3 p-lg-4 mb-4">
      <div class="filter-bar"><input v-model="search" type="search" placeholder="Rechercher un contenu...">
            <div class="chips">
                <button :class="{ active: activeCategory === 'Toutes' }" @click="activeCategory = 'Toutes'">Toutes</button>
                <button v-for="category in categories" :key="category" :class="{ active: activeCategory === category }" @click="activeCategory = category">{{ category }}</button>
            </div>
        </div>
    </section>
    <p class="small text-secondary">{{ filteredArticles.length }} contenu{{ filteredArticles.length > 1 ? 's' : '' }} trouvé{{ filteredArticles.length > 1 ? 's' : '' }}</p>
    <div class="row g-3">
      <div v-for="item in filteredArticles" :key="item.id" class="col-sm-6 col-lg-4">
        <article class="card border-0 shadow-sm h-100 content-card" tabindex="0" @click="$emit('open-article', item)" @keyup.enter="$emit('open-article', item)">
          <img :src="item.image" :alt="item.title" class="card-img-top object-fit-cover" :style="{ height: '180px', objectPosition: item.title.toLowerCase().includes('tressage') ? 'center bottom' : 'center' }">
          <div class="card-body"><div class="d-flex gap-1 flex-wrap mb-2"><span class="badge badge-tradition">{{ item.category || item.theme }}</span></div><h2 class="h6 fw-bold content-card-title">{{ item.title }}</h2><p class="small text-secondary mb-0 content-card-description">{{ item.village }}</p></div>
        </article>
      </div>
    </div>
    <p v-if="!filteredArticles.length" class="text-secondary py-4">Aucun contenu ne correspond à ces filtres.</p>
  </main>
</template>
