import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static targets = ['carousel', 'thumbnail', 'description', 'editButton']

  connect() {
    if (!this.hasCarouselTarget) {
      return
    }

    this.carousel = bootstrap.Carousel.getOrCreateInstance(this.carouselTarget)
    this.syncActiveSlide(this.activeCarouselItem())
  }

  select(event) {
    event.preventDefault()
    const index = Number(event.currentTarget.dataset.index)
    this.carousel.to(index)
    this.syncActiveSlide(this.carouselItems[index])
  }

  slideChanged(event) {
    this.syncActiveSlide(event.relatedTarget || this.activeCarouselItem())
  }

  syncActiveSlide(carouselItem) {
    if (!this.hasThumbnailTarget) {
      return
    }

    const activeIndex = this.carouselItems.indexOf(carouselItem)

    this.thumbnailTargets.forEach((thumbnail, currentIndex) => {
      const isActive = currentIndex === activeIndex
      thumbnail.classList.toggle('border-primary', isActive)
      thumbnail.classList.toggle('shadow-sm', isActive)
      if (isActive) {
        thumbnail.scrollIntoView({ block: 'nearest', inline: 'center', behavior: 'smooth' })
      }
    })

    if (this.hasDescriptionTarget && carouselItem) {
      const description = carouselItem.dataset.albumGalleryDescription || ''
      this.descriptionTarget.textContent = description || this.element.dataset.noDescription
    }

    if (this.hasEditButtonTarget && carouselItem) {
      const modalTarget = carouselItem.dataset.albumGalleryModalTarget
      if (modalTarget) {
        this.editButtonTarget.setAttribute('data-bs-target', `#${modalTarget}`)
      }
    }
  }

  activeCarouselItem() {
    return this.carouselItems.find(item => item.classList.contains('active')) || this.carouselItems[0]
  }

  get carouselItems() {
    return Array.from(this.carouselTarget.querySelectorAll('.carousel-item'))
  }
}