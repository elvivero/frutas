window.addEventListener("DOMContentLoaded", (_event) => {
  let carousels = []; // Current slide of carousels
  const carousel_nodes = document.querySelectorAll("div.carousel");
  [...carousel_nodes].forEach((carousel, id) => {
    const slides = carousel.querySelectorAll(".slides .slide");
    const n = slides.length;
    carousels.push(0);

    const indicator = carousel.querySelector(".indicator .current");

    const showSlide = (slide_n) => {
      slide_n = ((slide_n % n) + n) % n; // positive modulo
      slides[carousels[id]].classList.remove("active");
      slides[slide_n].classList.add("active");
      carousels[id] = slide_n;
      indicator.innerHTML = carousels[id] + 1;
    };

    carousel
      .querySelector("button.prev")
      .addEventListener("click", () => showSlide(carousels[id] - 1));

    carousel
      .querySelector("button.next")
      .addEventListener("click", () => showSlide(carousels[id] + 1));
  });
  console.log(carousels);
});
