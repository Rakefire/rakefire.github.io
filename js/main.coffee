---
---
weeksSinceFounding = ->
  founding = new Date(2015, 10, 6)
  today = new Date
  #Get 1 day in milliseconds
  one_day = 1000 * 60 * 60 * 24
  daysSinceFounding = (today.getTime() - founding.getTime()) / one_day
  daysSinceFounding / 7

ozToGallons = (oz) ->
  Math.floor oz / 8 / 16

ozToCups = (oz) ->
  Math.floor oz / 6.0

setGallonsOfCoffee = ->
  averageDailyOz = 32
  days = 6
  people = 2
  gallons = ozToGallons(averageDailyOz * days * people * weeksSinceFounding())
  $('#gallons-of-coffee').data 'to', gallons
  return

setCupsOfTea = ->
  averageDailyOz = 16
  days = 6
  people = 1
  cups = ozToCups(averageDailyOz * days * people * weeksSinceFounding())
  $('#cups-of-tea').data 'to', cups
  return

do ->
  'use strict'
  # iPad and iPod detection

  isiPad = ->
    navigator.platform.indexOf('iPad') != -1

  isiPhone = ->
    navigator.platform.indexOf('iPhone') != -1 or navigator.platform.indexOf('iPod') != -1

  # Parallax

  parallax = ->
    $(window).stellar()
    return

  # Burger Menu

  burgerMenu = ->
    $('body').on 'click', '.js-nav-toggle', (event) ->
      event.preventDefault()
      if $('#navbar').is(':visible')
        $(this).removeClass 'active'
      else
        $(this).addClass 'active'
      return
    return

  goToTop = ->
    $('.js-gotop').on 'click', (event) ->
      event.preventDefault()
      $('html, body').animate { scrollTop: $('html').offset().top }, 500
      false
    return

  # Page Nav

  isHomepage = ->
    $('body.index').length > 0

  clickMenu = ->
    # only do this for the homepage
    if isHomepage()
      $('#navbar a:not([class="external"])').click (event) ->
        section = $(this).data('nav-section')
        navbar = $('#navbar')
        if $('[data-section="' + section + '"]').length
          $('html, body').animate { scrollTop: $('[data-section="' + section + '"]').offset().top }, 500
        if navbar.is(':visible')
          navbar.removeClass 'in'
          navbar.attr 'aria-expanded', 'false'
          $('.js-nav-toggle').removeClass 'active'
        event.preventDefault()
        false
    return

  # Reflect scrolling in navigation

  navActive = (section) ->
    $el = $('#navbar > ul')
    $el.find('li').removeClass 'active'
    $el.each ->
      $(this).find('a[data-nav-section="' + section + '"]').closest('li').addClass 'active'
      return
    return

  navigationSection = ->
    $section = $('section[data-section]')
    $section.waypoint ((direction) ->
      if direction == 'down'
        navActive $(@element).data('section')
      return
    ), offset: '150px'
    $section.waypoint ((direction) ->
      if direction == 'up'
        navActive $(@element).data('section')
      return
    ), offset: ->
      -$(@element).height() + 155
    return

  # Window Scroll

  windowScroll = ->
    lastScrollTop = 0
    $(window).scroll (event) ->
      header = $('#header')
      scrlTop = $(this).scrollTop()
      if scrlTop > 500 and scrlTop <= 2000
        header.addClass 'navbar-fixed-top animated slideInDown'
      else if scrlTop <= 500
        if header.hasClass('navbar-fixed-top')
          header.addClass 'navbar-fixed-top animated slideOutUp'
          setTimeout (->
            header.removeClass 'navbar-fixed-top animated slideInDown slideOutUp'
            return
          ), 100
      return
    return

  # Animations
  # Home

  homeAnimate = ->
    if $('#home').length > 0
      $('#home').waypoint ((direction) ->
        if direction == 'down' and !$(@element).hasClass('animated')
          setTimeout (->
            $('#home .to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  introAnimate = ->
    if $('#intro').length > 0
      $('#intro').waypoint ((direction) ->
        if direction == 'down' and !$(@element).hasClass('animated')
          setTimeout (->
            $('#intro .to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInRight animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 1000
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  workAnimate = ->
    if $('#work').length > 0
      $('#work').waypoint ((direction) ->
        if direction == 'down' and !$(@element).hasClass('animated')
          setTimeout (->
            $('#work .to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  testimonialAnimate = ->
    testimonial = $('#testimonials')
    if testimonial.length > 0
      testimonial.waypoint ((direction) ->
        `var sec`
        if direction == 'down' and !$(@element).hasClass('animated')
          sec = testimonial.find('.to-animate').length
          sec = parseInt(sec * 200 - 400)
          setTimeout (->
            testimonial.find('.to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          setTimeout (->
            testimonial.find('.to-animate-2').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInDown animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), sec
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  servicesAnimate = ->
    services = $('#services')
    if services.length > 0
      services.waypoint ((direction) ->
        `var sec`
        if direction == 'down' and !$(@element).hasClass('animated')
          sec = services.find('.to-animate').length
          sec = parseInt(sec * 200 + 400)
          setTimeout (->
            services.find('.to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          setTimeout (->
            services.find('.to-animate-2').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'bounceIn animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), sec
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  aboutAnimate = ->
    about = $('#about')
    if about.length > 0
      about.waypoint ((direction) ->
        if direction == 'down' and !$(@element).hasClass('animated')
          setTimeout (->
            about.find('.to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  countersAnimate = ->
    counters = $('#counters')
    if counters.length > 0
      counters.waypoint ((direction) ->
        `var sec`
        if direction == 'down' and !$(@element).hasClass('animated')
          sec = counters.find('.to-animate').length
          sec = parseInt(sec * 200 + 400)
          setTimeout (->
            counters.find('.to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          setTimeout (->
            counters.find('.js-counter').countTo formatter: (value, options) ->
              value.toFixed options.decimals
            return
          ), 400
          setTimeout (->
            counters.find('.to-animate-2').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'bounceIn animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), sec
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  contactAnimate = ->
    contact = $('#contact')
    if contact.length > 0
      contact.waypoint ((direction) ->
        if direction == 'down' and !$(@element).hasClass('animated')
          setTimeout (->
            contact.find('.to-animate').each (k) ->
              el = $(this)
              setTimeout (->
                el.addClass 'fadeInUp animated'
                return
              ), k * 200, 'easeInOutExpo'
              return
            return
          ), 200
          $(@element).addClass 'animated'
        return
      ), offset: '80%'
    return

  setCupsOfTea()
  setGallonsOfCoffee()

  # Document on load.
  $ ->
    parallax()
    burgerMenu()
    clickMenu()
    windowScroll()
    navigationSection()
    goToTop()

    # Animations
    homeAnimate()
    introAnimate()
    workAnimate()
    testimonialAnimate()
    servicesAnimate()
    aboutAnimate()
    countersAnimate()
    contactAnimate()

    return
  return