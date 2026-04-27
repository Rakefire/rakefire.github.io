(function() {
  var ozToCups, ozToGallons, setCupsOfTea, setGallonsOfCoffee, weeksSinceFounding;

  weeksSinceFounding = function() {
    var daysSinceFounding, founding, one_day, today;
    founding = new Date(2015, 10, 6);
    today = new Date;
    one_day = 1000 * 60 * 60 * 24;
    daysSinceFounding = (today.getTime() - founding.getTime()) / one_day;
    return daysSinceFounding / 7;
  };

  ozToGallons = function(oz) {
    return Math.floor(oz / 8 / 16);
  };

  ozToCups = function(oz) {
    return Math.floor(oz / 6.0);
  };

  setGallonsOfCoffee = function() {
    var averageDailyOz, days, gallons, people;
    averageDailyOz = 32;
    days = 6;
    people = 2;
    gallons = ozToGallons(averageDailyOz * days * people * weeksSinceFounding());
    $('#gallons-of-coffee').data('to', gallons);
  };

  setCupsOfTea = function() {
    var averageDailyOz, cups, days, people;
    averageDailyOz = 16;
    days = 6;
    people = 1;
    cups = ozToCups(averageDailyOz * days * people * weeksSinceFounding());
    $('#cups-of-tea').data('to', cups);
  };

  (function() {
    'use strict';
    var aboutAnimate, burgerMenu, clickMenu, contactAnimate, countersAnimate, goToTop, homeAnimate, introAnimate, isHomepage, isiPad, isiPhone, navActive, navigationSection, parallax, servicesAnimate, testimonialAnimate, windowScroll, workAnimate;
    isiPad = function() {
      return navigator.platform.indexOf('iPad') !== -1;
    };
    isiPhone = function() {
      return navigator.platform.indexOf('iPhone') !== -1 || navigator.platform.indexOf('iPod') !== -1;
    };
    parallax = function() {
      $(window).stellar();
    };
    burgerMenu = function() {
      $('body').on('click', '.js-nav-toggle', function(event) {
        event.preventDefault();
        if ($('#navbar').is(':visible')) {
          $(this).removeClass('active');
        } else {
          $(this).addClass('active');
        }
      });
    };
    goToTop = function() {
      $('.js-gotop').on('click', function(event) {
        event.preventDefault();
        $('html, body').animate({
          scrollTop: $('html').offset().top
        }, 500);
        return false;
      });
    };
    isHomepage = function() {
      return $('body.index').length > 0;
    };
    clickMenu = function() {
      if (isHomepage()) {
        $('#navbar a:not([class="external"])').click(function(event) {
          var navbar, section;
          section = $(this).data('nav-section');
          navbar = $('#navbar');
          if ($('[data-section="' + section + '"]').length) {
            $('html, body').animate({
              scrollTop: $('[data-section="' + section + '"]').offset().top
            }, 500);
          }
          if (navbar.is(':visible')) {
            navbar.removeClass('in');
            navbar.attr('aria-expanded', 'false');
            $('.js-nav-toggle').removeClass('active');
          }
          event.preventDefault();
          return false;
        });
      }
    };
    navActive = function(section) {
      var $el;
      $el = $('#navbar > ul');
      $el.find('li').removeClass('active');
      $el.each(function() {
        $(this).find('a[data-nav-section="' + section + '"]').closest('li').addClass('active');
      });
    };
    navigationSection = function() {
      var $section;
      $section = $('section[data-section]');
      $section.waypoint((function(direction) {
        if (direction === 'down') {
          navActive($(this.element).data('section'));
        }
      }), {
        offset: '150px'
      });
      $section.waypoint((function(direction) {
        if (direction === 'up') {
          navActive($(this.element).data('section'));
        }
      }), {
        offset: function() {
          return -$(this.element).height() + 155;
        }
      });
    };
    windowScroll = function() {
      var lastScrollTop;
      lastScrollTop = 0;
      $(window).scroll(function(event) {
        var header, scrlTop;
        header = $('#header');
        scrlTop = $(this).scrollTop();
        if (scrlTop > 500 && scrlTop <= 2000) {
          header.addClass('navbar-fixed-top animated slideInDown');
        } else if (scrlTop <= 500) {
          if (header.hasClass('navbar-fixed-top')) {
            header.addClass('navbar-fixed-top animated slideOutUp');
            setTimeout((function() {
              header.removeClass('navbar-fixed-top animated slideInDown slideOutUp');
            }), 100);
          }
        }
      });
    };
    homeAnimate = function() {
      if ($('#home').length > 0) {
        $('#home').waypoint((function(direction) {
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            setTimeout((function() {
              $('#home .to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    introAnimate = function() {
      if ($('#intro').length > 0) {
        $('#intro').waypoint((function(direction) {
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            setTimeout((function() {
              $('#intro .to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInRight animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 1000);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    workAnimate = function() {
      if ($('#work').length > 0) {
        $('#work').waypoint((function(direction) {
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            setTimeout((function() {
              $('#work .to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    testimonialAnimate = function() {
      var testimonial;
      testimonial = $('#testimonials');
      if (testimonial.length > 0) {
        testimonial.waypoint((function(direction) {
          var sec;
          var sec;
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            sec = testimonial.find('.to-animate').length;
            sec = parseInt(sec * 200 - 400);
            setTimeout((function() {
              testimonial.find('.to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            setTimeout((function() {
              testimonial.find('.to-animate-2').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInDown animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), sec);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    servicesAnimate = function() {
      var services;
      services = $('#services');
      if (services.length > 0) {
        services.waypoint((function(direction) {
          var sec;
          var sec;
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            sec = services.find('.to-animate').length;
            sec = parseInt(sec * 200 + 400);
            setTimeout((function() {
              services.find('.to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            setTimeout((function() {
              services.find('.to-animate-2').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('bounceIn animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), sec);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    aboutAnimate = function() {
      var about;
      about = $('#about');
      if (about.length > 0) {
        about.waypoint((function(direction) {
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            setTimeout((function() {
              about.find('.to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    countersAnimate = function() {
      var counters;
      counters = $('#counters');
      if (counters.length > 0) {
        counters.waypoint((function(direction) {
          var sec;
          var sec;
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            sec = counters.find('.to-animate').length;
            sec = parseInt(sec * 200 + 400);
            setTimeout((function() {
              counters.find('.to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            setTimeout((function() {
              counters.find('.js-counter').countTo({
                formatter: function(value, options) {
                  return value.toFixed(options.decimals);
                }
              });
            }), 400);
            setTimeout((function() {
              counters.find('.to-animate-2').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('bounceIn animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), sec);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    contactAnimate = function() {
      var contact;
      contact = $('#contact');
      if (contact.length > 0) {
        contact.waypoint((function(direction) {
          if (direction === 'down' && !$(this.element).hasClass('animated')) {
            setTimeout((function() {
              contact.find('.to-animate').each(function(k) {
                var el;
                el = $(this);
                setTimeout((function() {
                  el.addClass('fadeInUp animated');
                }), k * 200, 'easeInOutExpo');
              });
            }), 200);
            $(this.element).addClass('animated');
          }
        }), {
          offset: '80%'
        });
      }
    };
    setCupsOfTea();
    setGallonsOfCoffee();
    $(function() {
      parallax();
      burgerMenu();
      clickMenu();
      windowScroll();
      navigationSection();
      goToTop();
      homeAnimate();
      introAnimate();
      workAnimate();
      testimonialAnimate();
      servicesAnimate();
      aboutAnimate();
      countersAnimate();
      contactAnimate();
    });
  })();

}).call(this);
