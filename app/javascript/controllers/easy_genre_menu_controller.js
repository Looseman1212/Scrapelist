import { Controller } from "@hotwired/stimulus"

let GROUPCOUNT = 0;

// Connects to data-controller="easy-genre-menu"
export default class extends Controller {
  connect() {
    console.log('easy-genre-menu controller connected')
  }

  scrollUp() {
    console.log('clicked up');
    const x = document.querySelectorAll('.easy-genre-menu-group');
    console.log(x);
  }

  scrollDown() {
    console.log('clicked down');
    const upButton = document.querySelector('.up-easy-menu-action');
    const downButton = document.querySelector('.down-easy-menu-action');
    const genreGroup = document.querySelectorAll('.easy-genre-menu-group');
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive');
    if (genreGroup[GROUPCOUNT + 1] != null) {
      genreGroup[GROUPCOUNT + 1].removeAttribute('id', 'inactive');
    } else if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].setAttribute('id', 'inactive');
    }
    GROUPCOUNT += 1;
    console.log(GROUPCOUNT);
    upButton.removeAttribute('id', 'inactive');
    if (GROUPCOUNT == 2) {
      downButton.setAttribute('id', 'inactive');
    }
  }
}
