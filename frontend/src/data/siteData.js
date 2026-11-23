import fandzaImage from '../assets/img/May.jpeg'
import tressageImage from '../assets/img/tr.jpg'
import artisteImage from '../assets/img/art.png'
import festivalImage from '../assets/img/mbiwi.jpeg'
import mariageImage from '../assets/img/myt.jpeg'
import soireeImage from '../assets/img/chigoma.png'
const traditionImage = fandzaImage
const heroImage = tressageImage

export const navigationLinks = [
  { id: 'accueil', label: 'Accueil' }, { id: 'explorer', label: 'Explorer' }, { id: 'evenements', label: 'Événements' }, { id: 'quiz', label: 'Quiz' }, { id: 'profil', label: 'Profil' },
]

export const categoryLabels = { festival: 'Festival', tradition: 'Tradition', ceremonie: 'Cérémonie' }

export const fallbackArticleImages = {
  'article-1': traditionImage,
  'article-2': heroImage,
  'article-3': traditionImage,
}

export const fallbackEventImages = {
  'event-1': festivalImage,
  'event-2': mariageImage,
  'event-3': soireeImage,
}

export const fallbackPlaceImage = artisteImage