function init_sliders(){
	$("#slider").slick({dots: true})
	$('.owl-carousel').owlCarousel({
		lazyLoad: true,
		margin: 0,
		nav: true,
		dots: true,
		autoHeight: true,
		responsiveClass: true,
		responsive:{
			0: {
				items: 1
			},
			320: {
				items: 2
			},
			640: {
				items: 3
			},
			920: {
				items: 4
			},
			1280: {
				items: 5
			},
			1440: {
				items: 6
			}
		}
	})
}
