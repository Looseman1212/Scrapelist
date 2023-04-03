import { Controller } from "@hotwired/stimulus"

let GROUPCOUNT = 0;

// Connects to data-controller="easy-genre-menu"
export default class extends Controller {
  connect() {
    // reset the iterator to 0 whenever the controller is connected
    GROUPCOUNT = 0;
  }

  scrollUp() {
    // define the buttons
    const upButton = document.querySelector('.up-easy-menu-action');
    const downButton = document.querySelector('.down-easy-menu-action');
    const genreGroup = document.querySelectorAll('.easy-genre-menu-group');
    // hide the current group
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    // show the previous group if there is one
    if (genreGroup[GROUPCOUNT - 1] != null) {
      genreGroup[GROUPCOUNT - 1].removeAttribute('id', 'inactive-list-group');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    GROUPCOUNT -= 1;
    // hide the up button if user is at the top of the menu
    if (GROUPCOUNT == 0) {
      upButton.setAttribute('id', 'inactive-button');
    } else {
      upButton.removeAttribute('id', 'inactive-button');
      downButton.removeAttribute('id', 'inactive-button');
    }
  }

  scrollDown() {
    // define the buttons
    const upButton = document.querySelector('.up-easy-menu-action');
    const downButton = document.querySelector('.down-easy-menu-action');
    const genreGroup = document.querySelectorAll('.easy-genre-menu-group');
    // hide the current group
    genreGroup[GROUPCOUNT].setAttribute('id', 'inactive-list-group');
    // show the next group if there is one
    if (genreGroup[GROUPCOUNT + 1] != null) {
      genreGroup[GROUPCOUNT + 1].removeAttribute('id', 'inactive-list-group');
    }
    // redefine the iterator after the change is shown to reflect where on the menu the user currently is
    GROUPCOUNT += 1;
    // hide the down button if user is at the bottom of the menu
    upButton.removeAttribute('id', 'inactive-button');
    if (GROUPCOUNT == 2) {
      downButton.setAttribute('id', 'inactive-button');
    } else {
      downButton.removeAttribute('id', 'inactive-button');
      upButton.removeAttribute('id', 'inactive-button');
    }
  }

  selectSurprise() {
    // define the radio buttons and the surprise button
    const radioButtons = document.getElementsByName('scrapelistprompt[genre]');
    const surpriseButton = document.getElementById('scrapelistprompt_genre_surprise');
    // create a random number between 0 and the number of radio buttons (not including the surprise button)
    const rand = Math.floor(Math.random() * (radioButtons.length - 1));
    if (rand == 0) {
      // if the random number is 0 (which would be the ALL button), set the surprise button value to acoustic
      surpriseButton.value = "acoustic"
      console.log(surpriseButton);
    } else {
      // otherwise, set the surprise button value to the value of a random radio button
      const randomValue = radioButtons[rand].value;
      surpriseButton.value = randomValue;
      console.log(surpriseButton);
    }
  }
}
