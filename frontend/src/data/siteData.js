import fandzaImage from '../assets/img/May.jpeg'
import tressageImage from '../assets/img/tr.jpg'
import artisteImage from '../assets/img/art.png'
import mbiwiImage from '../assets/img/mbiwi.jpeg'
import mariageImage from '../assets/img/myt.jpeg'
import soireeImage from '../assets/img/chigoma.png'
import histoireImage from '../assets/img/ANK.jpg'
import debaImage from '../assets/img/Déba.jpg'
import savoirFaireImage from '../assets/img/Savoir-faire.png'
import poterieImage from '../assets/img/poterie.jpg'
import tenueCeremonieImage from '../assets/img/tenue cérémonie.jpg'
import chakachaImage from '../assets/img/chakacha.jpg'
const traditionImage = fandzaImage
const heroImage = tressageImage

export const navigationLinks = [
  { id: 'accueil', label: 'Accueil' }, { id: 'explorer', label: 'Explorer' }, { id: 'evenements', label: 'Événements' }, { id: 'quiz', label: 'Quiz' }, { id: 'profil', label: 'Profil' },
]
export const libraryCategories = ['Histoires', 'Savoir-faire', 'Traditions']
export const categoryLabels = { festival: 'Festival', concert: 'Concert', tradition: 'Tradition', ceremonie: 'Cérémonie' }

export const fallbackArticleImages = {
  'article-1': traditionImage,
  'article-2': heroImage,
  'article-3': traditionImage,
  'Savoir-faire': poterieImage,
  Traditions: tenueCeremonieImage,
  Histoires: histoireImage,
}

export function getArticleFallbackImage(article) {
  const title = (article.title || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()
  if (title.includes('deba')) return debaImage
  if (title.includes('chakacha')) return chakachaImage
  if (title.includes('tressage')) return savoirFaireImage
  if (title.includes('poterie')) return poterieImage
  if (title.includes('mbiwi')) return mbiwiImage
  if (title.includes('mgodro') || title.includes('chigoma')) return soireeImage
  if (title.includes('ceremon') || title.includes('tenue traditionnelle') || title.includes('mariage')) {
    return tenueCeremonieImage
  }
  return fallbackArticleImages[article.category || article.theme] || fallbackArticleImages['article-1']
}

export function getArticleImage(article) {
  return article.imageUrl || getArticleFallbackImage(article)
}

export const culturalCategories = [
  {
    name: 'Histoires',
    description: 'Contes, légendes, récits historiques, personnages marquants et mémoire des villages.',
    image: histoireImage,
  },
  {
    name: 'Savoir-faire',
    description: 'Vannerie, tressage de feuilles de cocotier, poterie, artisanat et techniques traditionnelles.',
    image: poterieImage,
  },
  {
    name: 'Traditions',
    description: 'Mariages, cérémonies, vêtements traditionnels, coutumes et pratiques culturelles.',
    image: tenueCeremonieImage,
  },
]

export const fallbackEventImages = {
  'event-1': mbiwiImage,
  'event-2': mariageImage,
  'event-3': soireeImage,
}

export const fallbackPlaceImage = artisteImage