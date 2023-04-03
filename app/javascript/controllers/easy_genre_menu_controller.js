import { Controller } from "@hotwired/stimulus"

let GROUPCOUNT = 0;

// Connects to data-controller="easy-genre-menu"
export default class extends Controller {
  connect() {
    console.log('easy-genre-menu controller connected')
  }

  scrollUp() {
    console.log('clicked up');
    const upButton = document.querySelector('.up-easy-menu-action');
    const downButton = document.querySelector('.down-easy-menu-action');
    const genreGroup = document.querySelectorAll('.easy-genre-menu-group');
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].removeAttribute('id', 'inactive-list-group');
    }
    GROUPCOUNT -= 1;
    console.log(GROUPCOUNT);
    // upButton.removeAttribute('id', 'inactive-button');
    if (GROUPCOUNT == 0) {
      upButton.setAttribute('id', 'inactive-button');
    } else {
      upButton.removeAttribute('id', 'inactive-button');
      downButton.removeAttribute('id', 'inactive-button');
    }
  }

  scrollDown() {
    console.log('clicked down');
    const upButton = document.querySelector('.up-easy-menu-action');
    const downButton = document.querySelector('.down-easy-menu-action');
    const genreGroup = document.querySelectorAll('.easy-genre-menu-group');
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    if (genreGroup[GROUPCOUNT + 1] != null) {
      genreGroup[GROUPCOUNT + 1].removeAttribute('id', 'inactive-list-group');
    } else if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].setAttribute('id', 'inactive-list-group');
    }
    GROUPCOUNT += 1;
    console.log(GROUPCOUNT);
    upButton.removeAttribute('id', 'inactive-button');
    if (GROUPCOUNT == 2) {
      downButton.setAttribute('id', 'inactive-button');
    } else {
      downButton.removeAttribute('id', 'inactive-button');
      upButton.removeAttribute('id', 'inactive-button');
    }
  }
}
